# coding: utf-8
# 基本 Model，加入一些通用功能
module Mongoid
  module BaseModel
    extend ActiveSupport::Concern

    included do
      # scope :recent, desc(:_id)
      # scope :exclude_ids, Proc.new { |ids| where(:_id.nin => ids.map(&:to_i)) }
      
      delegate :url_helpers, to: 'Rails.application.routes'
    end
    
    def update_last_reply(reply)
      # replied_at 用于最新回复的排序，如果贴着创建时间在一个月以前，就不再往前面顶了
      self.last_active_mark = Time.now.to_i if self.created_at > 1.month.ago
      self.replied_at = Time.now
      self.last_reply_id = reply.id
      self.last_reply_account_id = reply.account_id
      self.last_reply_account_login = reply.account.try(:login) || nil
      self.save
    end

    module ClassMethods
      # like ActiveRecord find_by_id
      def find_by_id(id)
        if id.is_a?(Integer) or id.is_a?(String)
          where(:_id => id.to_i).first
        else
          nil
        end
      end

      def find_in_batches(opts = {})
        batch_size = opts[:batch_size] || 1000
        start = opts.delete(:start).to_i || 0
        objects = self.limit(batch_size).skip(start)
        t = Time.new
        while objects.any?
          yield objects
          start += batch_size
          # Rails.logger.debug("processed #{start} records in #{Time.new - t} seconds") if Rails.logger.debug?
          break if objects.size < batch_size
          objects = self.limit(batch_size).skip(start)
        end
      end
      
      def delay
        Sidekiq::Extensions::Proxy.new(DelayedDocument, self)
      end
      
    end
    
    def delay
      Sidekiq::Extensions::Proxy.new(DelayedDocument, self)
    end
    
  end
end
