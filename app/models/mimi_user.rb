# coding: utf-8
require "digest/md5"
require "open-uri"  
require 'cgi'
require 'json'
class MimiUser
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :phone
  field :phone_md5
  field :code
  field :token
  
  #publish
  def publish(msg)
    mt = MimiTopic.new(:msg => msg)
    mt.mimi_user_id = self.id
    mt.phone_md5 = self.phone_md5
    if mt.save
      {:status =>"1", "msg" => "发布成功~" }
    else
      {:status =>"0", "msg" => "发失败鸟~" }
    end
  end
  
  #发表评论
  def pub_comment(msg_id,content)
    mt = MimiTopic.find msg_id
    if mt
      mtr = MimiTopicReply.new(:content => content)
      mtr.mimi_topic_id = mt.id
      mtr.mimi_user_id = self.id
      mt.phone_md5 = self.phone_md5
      if mtr.save
        {:status =>"1", "msg" => "评论成功~" }
      else
        {:status =>"0", "msg" => "评论失败鸟~" }
      end
    else
      {:status =>"0", "msg" => "消息不存在~" }
    end
  end
  
  def get_timeline(page,per_page)
    scoped_items = MimiTopic.all
    @items = scoped_items.paginate  :per_page => per_page, :page =>  page 
  end
  
  def get_comment(msg_id,page,per_page)
    scoped_items = MimiTopicReply.normal
    @items = scoped_items.by_msg_id(msg_id).paginate  :per_page => per_page, :page =>  page
  end
  
  def self.try_login(token)
    a = MimiUser.where(:token => token).first if token 
    a ? a : nil
  end
  
  def self.try_login_by_code(phone_md5,code)
    a = MimiUser.where(:phone_md5 => phone_md5).first if phone_md5 
    if (a && a.code == code)
      {:status =>"1", "token" => "#{a.token}" }
    else
      {:status =>"0", "msg" => "登录失败，请检查你的短信验证码~" }
    end
  end
  
  #upload
  def upload_contacts(contacts)
    jcontacts = JSON.parse(contacts)
    logger.info "contacts:#{jcontacts}"
    jcontacts.each do |c|
      phone_md5 = c['phone_md5']
      mc = MimiContact.where(:phone_md5 => phone_md5,:mini_user_id => self.id).first
      unless mc
        mc = MimiContact.new(:phone_md5 => phone_md5)
        mc.u_phone_md5 = self.phone_md5
        mc.mimi_user_id = self.id
        mc.save
      end
    end
  end
  
  def self.get_user(phone)
    u  = MimiUser.where(:phone => phone).first 
    unless u
      u = MimiUser.e(:phone => phone)
      u.save
      u
    else
      u
    end
  end
  
  #send sms code
  def self.send_code(phone)
    unless phone.blank?
      @u = MimiUser.get_user(phone)
      logger.info "phone:#{phone},u:#{@u.phone}"
      message = "验证码:#{@u.code}（半小时内有效）-极客学院"
      uri = "http://www.xxx.com/sendsms?id=xx&phone=#{@u.phone}&message=#{CGI::escape(message)}"
      logger.info("uri:#{uri}")
      html_response = nil  
      open(uri) do |http|  
        html_response = http.read  
      end
      logger.info "html_response:#{html_response}"
      if html_response
        {:status =>"1", "msg" => "请查看收到的短信验证码(#{@u.try(:code)})~" }
      else
        {:status =>"0", "msg" => "短信发送失败，请稍后再试~" }
      end
    else
      {:status =>"0", "msg" => "手机号码为空~" }
    end
  end
  
  #after_save
  after_create :gen_token_and_phone_md5
  
  def gen_token_and_phone_md5
    token = "#{SecureRandom.hex(6)}"
    self.update_attribute(:token, token)
    
    code = MimiUser.rand_code(4)
    self.update_attribute(:code, code)
    
    phone_md5 = Digest::MD5.hexdigest(phone || "")
    self.update_attribute(:phone_md5, phone_md5)
  end
  
  
  def self.rand_code(len=4)
    #("a".."z").to_a + ("A".."Z").to_a + 
    chars = ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  
  
end