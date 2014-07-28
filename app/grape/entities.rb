require "digest/md5"

module APIEntities

  
  class MimiTopic < Grape::Entity
    expose  :msg,:msgId,:phone_md5,:created_at
  end
  
  class MimiTopicReply < Grape::Entity
    expose  :rid,:content,:phone_md5,:created_at
  end
 
  
 
  

    
  
end
