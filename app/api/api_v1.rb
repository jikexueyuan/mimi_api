# coding: utf-8
#Api
#Get（先用get测，测试完成后再换成post）
#入口: http://demo.eoeschool.com/nimings/io?action=xxx
#返回: status-状态；msg-提示信息
#Todo:连发送短信的接口发短信；
class Api_v1 < Grape::API
  version 'v1', :using => :path,  :format => :json #,:vendor => 'acme'
  helpers APIHelpers
  

  resource :nimings do 
    get '/hey' do 
      "say hey from NiMing " 
    end
    
    post '/io' do
      act = params[:action]
      if act == "send_pass"
        MimiUser.send_code(params[:phone])
      elsif act == "login"
        code = params[:code]
        phone_md5 = params[:phone_md5]
        MimiUser.try_login_by_code(phone_md5,code)
      else
        authenticate!
        case act 
        #上传联系人
        when "upload_contacts"
          contacts = params[:contacts]
          if(current_user.upload_contacts(contacts))
            {:status =>"1", "msg" => "成了~" }
          else
            {:status =>"0", "msg" => "失败鸟~" }
          end
        #消息列表
        when "timeline"
          page = params[:page] || 1
          prepage = params[:prepage] || 10
          @items = current_user.get_timeline(page,prepage)
          present @items, :with => APIEntities::MimiTopic
          body( { status: "1", items: body() }) 
        #获取评论
        when "get_comment"
          msg_id = params[:msgId]
          page = params[:page] || 1
          prepage = params[:prepage] || 10
          @comments = current_user.get_comment(msg_id,page,prepage)
          present @comments, :with => APIEntities::MimiTopicReply
          body( { status: "1", items: body() }) 
        #发布消息
        when "publish"
          msg = params[:msg]
          current_user.publish(msg)
        #发布评论
        when "pub_comment"
          content = params[:content]
          msg_id = params[:msgId]
          current_user.pub_comment(msg_id,content)
        else
        end
      end

    end
    
  end
  

  

end #end class