# coding: utf-8
class MimisController < ApplicationController
    
    def index
      @users = MimiUser.paginate(:page => params[:page], :per_page => 1000)
      @topics = MimiTopic.paginate(:page => params[:page], :per_page => 1000)
      @replies = MimiTopicReply.paginate(:page => params[:page], :per_page => 1000)
      @contacts = MimiContact.paginate(:page => params[:page], :per_page => 1000)
    end
end
