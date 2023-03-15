# aspace-plugin-primo
This is a plugin for ArchivesSpace that allows a user of the public interface to click a link at any level of description for a given resource (resource or archival object) and be taken to the corresponding record in Primo.
When an ArchivesSpace resource page loads, the PrimoLinkBuilder class constructs the url to the resource in Primo, and inserts a link into the ArchivesSpace page next to the other clickable actions.
Note: an earlier iteration of the plugin allowed us to do a 2 step process, using the mms id to query for a document id from Alma, and then building the link with the document id. Our institutional alliance has since moved to Primo VE and the code has been simplified to use the mms id to build the link.

### Requirements
Creating and using this plugin was considerably simplified by the addition of each resource's mms id to its metadata in ArchivesSpace; in our case the mms id is stored in the user_defined string_2 field. 
You will need to know the base url for your institution's Primo and view id. The most difficult part of setting this plugin up may be getting the url correctly constructed; debugging them directly in the browser was useful.
Once obtained, those values can be added to the AppConfig with the following keys:
:primo_base_url
:vid_view
