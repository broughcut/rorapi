require 'leaves/search_api'
class Rorapi < Autumn::Leaf

#  before_filter :authenticate, :only => [ :reload, :quit ]
 
  def git_command(stem,sender,reply_to,msg)
    reply_to = msg if msg 
    response = "http://github.com/broughcut/rorapi"
    message(response,reply_to)
  end

  def usage_command(stem,sender,reply_to,msg)
    reply_to = msg if msg 
    response = "'?to_json' '?json:fuzzy' '?to_json:all' '?to_json:se' '?to_json:var' '?method:baz:ba' '?method:args nick' '/rorapi ?method:args'"
    message(response,reply_to)
  end

  def define_command(stem,sender,reply_to,define,msg)
    faq = YAML::load(File.read('leaves/api_docs/rails_faq.yml'))
    definition = msg.gsub(/\*$|<<|>>|\s{2,}/){}.strip
    definition_set = definition.split(',')
    definition_set.map! {|it| it.strip}
    if msg =~ /^<</
      faq[define] ||= []
      if faq[define].is_a?(Array)
        faq[define] << definition_set
        faq[define].flatten!
        faq[define].uniq!
      end
    elsif faq[define] && msg =~ /^>>/
      faq[define].delete(definition)
    elsif faq[define] && msg =~ /\*$/ || !faq[define]
      faq[define] = definition
    end
    File.open("leaves/api_docs/rails_faq.yml","w+") {|f| f.puts faq.to_yaml}
  end

  def q_command(stem,sender,reply_to,msg,detail=false)
    query = msg.split(' ')
    reply_to = query[1].gsub(/#/){} if query.size > 1 
    detail = true if query.size > 1
    response = 'not found'
    if query.first =~ /^\?/
      faq = YAML::load(File.read('leaves/api_docs/rails_faq.yml'))
      item = faq.select {|it| it == query.first.gsub(/\W/){}.to_sym}.values.first
      response = item
      response = item.join(', ') if item.is_a?(Array)
    else
      response = search(query.first,detail)
    end
     message(response,reply_to)
  end

  alias Q_command q_command


  private

  def authenticate_filter(stem, channel, sender, command, msg, opts)
    not ([ :operator, :admin, :founder, :channel_owner ] & [ stem.privilege(channel, sender) ].flatten).empty?
  end
end
