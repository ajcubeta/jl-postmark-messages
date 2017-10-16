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
      payload = @webhook.payload
      Rails.logger.info "Webhook payload : #{payload}"
      Rails.logger.info "Webhook payload class : #{payload.class}"
      # payload_as_json = payload.as_json.with_indifferent_access #ActiveSupport::HashWithIndifferentAccess
      # Rails.logger.info "Webhook payload to json : #{payload_as_json}"

      Rails.logger.info "Parse Payload : #{JSON.parse(payload)}"
      load = JSON.parse(payload)
      Rails.logger.info "Webhook payload parsed MessageID: #{load['MessageID']}"
      # Rails.logger.info "Webhook ID: #{@webhook.id} and MessageID is #{@webhook.payload[:MessageID]}"
      # @webhook.migrate_message!
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
