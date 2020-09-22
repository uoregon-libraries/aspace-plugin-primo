require 'json'

class PrimoLinkBuilder
  include PrimoRequest

  def initialize(record)
    @record = record
  end

  def mms(resource_record=@record)
    @mms_id ||= resource_record['json']['user_defined']['string_2']
  rescue
    return nil
  end

  def is_archival_object
    @record['json']['uri'].include? 'archival_object'
  end

  def resource_id
    @record['json']['resource']['ref']
  end

  def archivesspace
    @archivesspace ||= ArchivesSpaceClient.new
  end

  def get_resource_record
    archivesspace.get_record(resource_id)
  end

  def get_link
    resource_record = is_archival_object ? get_resource_record : @record
    return "#{AppConfig[:public_url]}/500.html" if mms(resource_record).nil?

    build_link
  end

  def build_link
    response = request(query_url)
    return "#{AppConfig[:public_url]}/500.html" if response.nil?

    json = JSON.parse(response.body)['docs'][0]["@id"]
    docid = json.split('/pnxs/L/').last
    "#{ENV['PRIMOBASEURL']}/primo-explore/fulldisplay?" + viewParams(docid)
  rescue StandardError => e
    Rails.logger.warn("from PrimoLinkBuilder: #{e.message}")
    return "#{AppConfig[:public_url]}/500.html"
  end

  def query_url
    URI(ENV['APIBASEURL'] + '/primo/v1/search?' + queryParams)
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
