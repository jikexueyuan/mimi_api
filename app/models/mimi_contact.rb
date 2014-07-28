# coding: utf-8
class MimiContact
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :phone_md5
  field :u_phone_md5
  belongs_to :mimi_user
  
  
end