require 'json'

class PrimoLinkBuilder
  include PrimoRequest

  RESPOND_500 = "#{AppConfig[:public_url]}/500.html"

  def initialize(record)
    @record = record
  end

  def mms(resource_record=@record)
    @mms_id ||= resource_record['json']['user_defined']['string_2']
  rescue StandardError
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
    return archivesspace.get_record(resource_id) if is_archival_object

    return @record
  rescue StandardError => e
    Rails.logger.warn("from PrimoLinkBuilder: #{e.message}")
    return nil
  end

  def get_link
    resource_record = get_resource_record
    return RESPOND_500 if resource_record.nil?

    return RESPOND_500 if mms(resource_record).nil?

    build_link
  end

  def build_link
    response = request(query_url)
    return RESPOND_500 if response.nil?

    json = JSON.parse(response.body)['docs'][0]["@id"]
    docid = json.split('/pnxs/L/').last
    "#{AppConfig[:primo_base_url]}/primo-explore/fulldisplay?" + viewParams(docid)
  rescue StandardError => e
    Rails.logger.warn("from PrimoLinkBuilder: #{e.message}")
    return RESPOND_500
  end

  def query_url
    URI(AppConfig[:api_base_url] + '/primo/v1/search?' + queryParams)
  end

  def viewParams(docid)
    "docid=#{ERB::Util.url_encode(docid)}&" +
    "context=L&" +
    "vid=#{ERB::Util.url_encode(AppConfig[:vid_view])}&" +
    "tab=default_tab&" +
    "search_scope=default_scope&" +
    "adaptor=Local%20Search%20Engine&" +
    "lang=en_US"
  end

  def queryParams
    "inst=#{ERB::Util.url_encode(AppConfig[:inst])}&" +
    "vid=#{ERB::Util.url_encode(AppConfig[:vid_search])}&" +
    "tab=default_tab&" +
    "scope=default_scope&" +
    "q=any,contains,#{ERB::Util.url_encode(mms)}&" +
    "apikey=#{ERB::Util.url_encode(AppConfig[:primo_apikey])}"
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
