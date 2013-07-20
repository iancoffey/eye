class Eye::Notify
  include Celluloid
  extend Eye::Dsl::Validation

  autoload :Mail,     'eye/notify/mail'
  autoload :Jabber,   'eye/notify/jabber'

  TYPES = {:mail => "Mail", :jabber => "Jabber"}

  def self.get_class(type)
    klass = eval("Eye::Notify::#{TYPES[type]}") rescue nil
    raise "Unknown notify #{type}" unless klass
    klass
  end

  def self.validate!(options)
    get_class(options[:type]).validate(options)
  end

  def self.notify(contact, message_h)
    contact = contact.to_s
    settings = Eye::ctrl.settings
    needed_hash = (settings[:contacts] || {})[contact]

    if needed_hash.blank?
      error "not found contact #{contact}! something wrong with config"
      return
    end

    create_proc = lambda do |nh|
      type = nh[:type]
      config = (settings[type] || {}).merge(nh[:opts] || {}).merge(:contact => nh[:contact])
      klass = get_class(type)
      notify = klass.new(config, message_h)
      notify.async_notify if notify
    end

    if needed_hash.is_a?(Array)
      needed_hash.each{|nh| create_proc[nh] }
    else
      create_proc[needed_hash]
    end
  end

  TIMEOUT = 1.minute

  def initialize(options = {}, message_h = {})
    @message_h = message_h
    @options = options

    debug "created notifier #{options}"
  end

  def logger_sub_tag
    @options[:contact]
  end

  def async_notify
    async.notify
    after(TIMEOUT){ terminate }
  end

  def notify
    debug "start notify #{@message_h}"
    execute
    debug "end notify #{@message_h}"
    terminate
  end

  def execute
    raise "realize me"
  end

  param :contact, [String]

  def message_subject
    "[#{msg_host}] [#{msg_full_name}] #{msg_message}"
  end

  def message_body
    "#{message_subject} at #{msg_at.to_s(:short)}"
  end

private

  %w{at host message name full_name pid level}.each do |name|
    define_method("msg_#{name}") do
      @message_h[name.to_sym]
    end
  end

end