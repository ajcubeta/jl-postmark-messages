class OutboundWebhooksController < ApplicationController
  protect_from_forgery except: [:delivery, :bounce, :opens]
  before_action :authenticate

  def index
    @title = "Outbound Webhooks"
    @webhooks = OutboundWebhook.paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @title = "Outbound Webhook Show"
    @webhook = OutboundWebhook.find(params[:id])
  end

  def delivery
    request.body.rewind
    @webhook = OutboundWebhook.new(payload: request.body.read, webhook_type: 'Delivered')

    if @webhook.save
      begin
        payload = @webhook.payload
        parsed_payload = JSON.parse(payload)
        Rails.logger.info "Delivery Webhook payload parsed MessageID: #{parsed_payload['MessageID']}"
        MessageDetail.import_message_detail(parsed_payload['MessageID'])
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect} : #{parsed_payload['MessageID']}"
        ErrorMailer.notify_sysadmin("Importing message details from postmark has error #{parsed_payload['MessageID']}", e.message, e.backtrace).deliver
      end

      render json: @webhook, status: :created
    else
      render json: @webhook.errors, status: :unprocessable_entity
    end
  end

  def bounce
    request.body.rewind
    @webhook = OutboundWebhook.new(payload: request.body.read, webhook_type: 'Bounced')

    if @webhook.save
      render json: @webhook, status: :created
    else
      render json: @webhook.errors, status: :unprocessable_entity
    end
  end

  def opens
    request.body.rewind
    @webhook = OutboundWebhook.new(payload: request.body.read, webhook_type: 'Opened')

    if @webhook.save

      begin
        payload = @webhook.payload
        parsed_payload = JSON.parse(payload)
        Rails.logger.info "Opens Webhook payload parsed MessageID: #{parsed_payload['MessageID']}"
        MessageDetail.import_message_detail(parsed_payload['MessageID'])
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect} : #{parsed_payload['MessageID']}"
        ErrorMailer.notify_sysadmin("Importing message details from postmark has error #{parsed_payload['MessageID']}", e.message, e.backtrace).deliver
      end

      render json: @webhook, status: :created
    else
      render json: @webhook.errors, status: :unprocessable_entity
    end
  end

  def click
    request.body.rewind
    @webhook = OutboundWebhook.new(payload: request.body.read, webhook_type: 'Clicked')

    if @webhook.save
      render json: @webhook, status: :created
    else
      render json: @webhook.errors, status: :unprocessable_entity
    end
  end

  def delivered_outbound_messages
    @title = "Outbound Webhooks - Delivered"
    @webhooks = OutboundWebhook.where(webhook_type: 'Delivered').all
  end

  def bounced_outbound_messages
    @title = "Outbound Webhooks - Bounced"
    @webhooks = OutboundWebhook.where(webhook_type: 'Bounced').all
  end

  def opened_outbound_messages
    @title = "Outbound Webhooks - Opened"
    @webhooks = OutboundWebhook.where(webhook_type: 'Opened').all
  end

  def clicked_outbound_messages
    @title = "Outbound Webhooks - Clicked"
    @webhooks = OutboundWebhook.where(webhook_type: 'Clicked').all
  end
end
