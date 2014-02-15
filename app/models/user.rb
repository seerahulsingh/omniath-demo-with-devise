class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :open_id, :google, :google_apps, :twitter, :linkedin]
  

  validates :email, uniqueness: true
	def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    # raise auth.to_yaml
  		user = User.where(email: auth.info.email).first
  		unless user
    		user = User.create(name:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20]
                         )
  		end
  		user
	end

 # # Notice that Devise RegistrationsController by default calls "User.new_with_session" 
 # # before building a resource. This means that, if we need to copy data from session 
 # # whenever a user is initialized before sign up, we just need to implement new_with_session 
 # # in our model. Here is an example that copies the facebook email if available


 # def self.new_with_session(params, session)
 #    	super.tap do |user|
 #      		if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
 #        		user.email = data["email"] if user.email.blank?
 #      		end
 #    	end
 #  	end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(name: data["name"],
             email: data["email"],
             password: Devise.friendly_token[0,20]
            )
    end
    user
  end

  def self.find_for_open_id(access_token, signed_in_resource=nil)
     # raise access_token.to_yaml
    data = access_token.info
    if user = User.where(:email => data["email"]).first
      user
    else
      User.create!(:email => data["email"], :password => Devise.friendly_token[0,20])
    end
  end

  def self.find_for_open_id(access_token, signed_in_resource=nil)
    data = access_token.info
    if user = User.where(:email => data["email"]).first
      user
    else
      User.create!(:email => data["email"], :password => Devise.friendly_token[0,20])
    end
  end


  def self.find_for_googleapps_oauth(access_token, signed_in_resource=nil)
    data = access_token['info']
  
    if user = User.where(:email => data['email']).first 
      return user
    else #create a user with stub pwd
      User.create!(:email => data['email'], :password => Devise.friendly_token[0,20])
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.googleapps_data'] && session['devise.googleapps_data']['user_info']
        user.email = data['email']
      end
    end
  end

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.uid + "@twitter.com").first
      if registered_user
        return registered_user
      else

        user = User.create(name:auth.extra.raw_info.name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.uid+"@twitter.com",
                            password:Devise.friendly_token[0,20],
                          )
      end
    end
  end

  def self.connect_to_linkedin(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else

        user = User.create(name:auth.info.first_name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.info.email,
                            password:Devise.friendly_token[0,20],
                          )
      end

    end
  end   

 protected
    def confirmation_required?
      false
    end
end
