# aspace-plugin-primo
This is a plugin for ArchivesSpace that allows a user of the public interface to click a link at any level of description for a given resource (resource or archival object) and be taken to the corresponding record in Primo.
When an ArchivesSpace resource page loads, the PrimoLinkBuilder class queries the Primo API to get the resource's document id, constructs the url to the resource in Primo, and inserts a link into the ArchivesSpace page next to the other clickable actions.

### Requirements
Creating and using this plugin was considerably simplified by the addition of each resource's mms id to its metadata in ArchivesSpace; in our case the mms id is stored in the user_defined string_2 field. 
In order to make calls to the Primo API, it is necessary to first register with ExLibris and also acquire an API key.
You will need to know the base API url (e.g. https://api-na.hosted.exlibrisgroup.com), the base url for your institution's Primo, your institutional id, and view id. As the UO is part of a consortium, the view id used in the initial request to the API is different than the one used to create the Primo redirect link. The most difficult part of setting this plugin up may be getting these two urls correctly constructed; debugging them directly in the browser was useful.
Once obtained, those values can be added to the AppConfig with the following keys:
:primo_apikey,
:api_base_url,
:primo_base_url,
:inst,
:vid_search,
:vid_view
