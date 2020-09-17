require 'json'

class PrimoLinkBuilder
  include PrimoRequest

  def initialize(record)
    @record = record
  end

  def mms
    @record['json']['user_defined']['string_2']
  rescue
    return nil
  end

  #not trying to use this yet.
  def hide_link?
    mms.nil?
  end

  def build_link
    return "#{AppConfig[:public_url]}/500.html" if mms.nil?

    url = URI(ENV['APIBASEURL'] + '/primo/v1/search?' + queryParams)
    response = request(url)
    return "#{AppConfig[:public_url]}/500.html" if response.nil?

    json = JSON.parse(response.body)['docs'][0]["@id"]
    docid = json.split('/pnxs/L/').last
    "#{ENV['PRIMOBASEURL']}/primo-explore/fulldisplay?" + viewParams(docid)
  rescue StandardError => e
    Rails.logger.warn("from PrimoLinkBuilder: #{e.message}")
    return nil
  end

  def viewParams(docid)
    "docid=#{ERB::Util.url_encode(docid)}&" +
    "context=L&" +
    "vid=#{ERB::Util.url_encode(ENV['VID_VIEW'])}&" +
    "tab=default_tab&" +
    "search_scope=default_scope&" +
    "adaptor=Local%20Search%20Engine&" +
    "lang=en_US"
  end

  def queryParams
    "inst=#{ERB::Util.url_encode(ENV['INST'])}&" +
    "vid=#{ERB::Util.url_encode(ENV['VID_SEARCH'])}&" +
    "tab=default_tab&" +
    "scope=default_scope&" +
    "q=any,contains,#{ERB::Util.url_encode(mms)}&" +
    "apikey=#{ERB::Util.url_encode(ENV['APIKEY'])}"
  end

  def request(url)
    get(url) do |response|
      if response.code != '200'
        return nil
      else
        response
      end
    end
  rescue StandardError => e
    Rails.logger.warn("from PrimoLinkBuilder: #{e.message}")
    return nil
  end
end
