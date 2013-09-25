require 'bcrypt'

class User
	include DataMapper::Resource

  attr_reader :password
  attr_accessor :password_confirmation

  # this is datamapper's method of validating the model.

  validates_confirmation_of :password, :message => "Sorry, your passwords don't match"

	property :id, Serial
	property :email, String, :unique => true, :message => "This email is already taken"

	property :password_digest, Text
	# when assigned the password, we don't store it directly
  	# instead, we generate a password digest, that looks like this:
  	# "$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa"
  	# and save it in the database. This digest, provided by bcrypt,
  	# has both the password hash and the salt. We save it to the 
  	# database instead of the plain password for security reasons.

  	def password=(password)
      @password = password
  		self.password_digest = BCrypt::Password.create(password)
  	end

    def self.authenticate(email,password)
      user = first(:email => email)
      # if this user exists and the password provided matches
      # the one we have password_digest for then ok.

      # The password.new returns an object that overrides the ==
      # method. Instead of comparing 2 passwords directly
      # (which is impossible because we only have a one-way hash)
      # the == method calculates the candidate password_digest 
      # from the password given and compares it to the password_digest
      # it was initialised with.
      # This is NOT a string comparison
      if user && BCrypt::Password.new(user.password_digest) == password
        # return
        user
      else
        nil
      end
    end

end