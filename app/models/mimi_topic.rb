# coding: utf-8
class MimiTopic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  
  field :msg 
  field :phone_md5 
  field :state, :type => Integer, :default => 1
  
  
  belongs_to :mimi_user
  
  scope :normal, -> { where(:state.gt => 0) }
  
  def msgId
    self.id.to_s
  end
end