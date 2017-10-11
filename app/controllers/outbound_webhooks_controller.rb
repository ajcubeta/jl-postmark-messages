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
      @webhook.migrate_message!
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
end
