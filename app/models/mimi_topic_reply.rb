# coding: utf-8
class MimiTopicReply
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :content
  field :phone_md5  
  belongs_to :mimi_topic
  belongs_to :mimi_user
  
  
  scope :by_msg_id,  Proc.new { |t| where(:mimi_topic_id => t) }
  scope :normal, -> { where(:state.gt => 0) }
  
  
  def rid
    self.id.to_s
  end
  
end