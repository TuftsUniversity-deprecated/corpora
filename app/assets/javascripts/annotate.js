

// after the page is loaded, init variables holding people, concepts and places
//  and annotate the transcript
jQuery(document).ready(initDataAndTabs);



// the functions initPeople, initConcepts and initPlaces are created
//   by code in AnnotationHelper, they return json data for people, places and concepts
function initDataAndTabs()
{
    initConfigHash();
    var people = initPeople();
    addType(people, "person");
    extraData.person.data = people;

    var concepts = initConcepts();
    addType(concepts, "concept");
    extraData.concept.data = concepts;

    var places = initPlaces();
    addType(places, "place");
    extraData.place.data = places;

    // add all the data to a single array
    elements = people.concat(concepts, places);
    initTabs();
    annotateTranscript();

    // init map on first display due to a resize bug
    //initMap();
    //initMarkers();
    showMapCanvas();

    var mapTab = jQuery("#tab4");
    mapTab.on("click", function(){delayedInitMap();})
};

// this is a temporary fix
// if the map is created on page load it displays incorrectly
//   because it doesn't receive a resize when the div is initialized after its first display
//   so the map still zero size
function delayedInitMap()
{
    if (map == null)
    {
        initMap();
        initMarkers();
        google.maps.event.trigger(map, 'resize');
    }
}

// hold details like div name and detailed template for each of the person, concept and place
var extraData;

// init details like div name and detailed template for each of the person, concept and place
// when ready to add events, add event hash to this hash, and add function to initialize event data
function initConfigHash()
{
    extraData = {
        'person': {'name': 'person', 'tabId': '#tab3',
            'divId': '#peopleDiv',
            'detailTemplate': "{{name}}<br/><div class='elementDescription'>Description: {{description}}</div><br/><div class='elementLink>'>Link: <a href='{{link}}' target='_blank'>{{link}}</a></div><br/>{{#image_link}}<div class='description-image'><img src='{{image_link}}'></div>{{/image_link}}Appearances in this interview:<div id='{{type}}InternalReferences'></div><br/>Also mentioned in these interviews:<div id='{{type}}ExternalReferences'></div><div class='description-link'><a href='javascript:showList(\"{{type}}\")'>Show {{type}} list</a></div>"},

        'concept': {'name': 'concept', 'tabId': '#tab5',
            'divId': '#conceptsDiv',
            'detailTemplate': "{{name}}<br/><div class='elementDescription'>Description: {{description}}</div><br/><div class='elementLink>'>Link: <a href='{{link}}' target='_blank'>{{link}}</a></div><br/>{{#image_link}}<div class='description-image'><img src='{{image_link}}'></div>{{/image_link}}Appearances in this interview:<div id='{{type}}InternalReferences'></div><br/>Also mentioned in these interviews:<div id='{{type}}ExternalReferences'></div><div class='description-link'><a href='javascript:showList(\"{{type}}\")'>Show {{type}} list</a></div>"},

        'place': {'name': 'place', 'tabId': '#tab4',
            'divId': '#placesDiv',
            'detailTemplate': "{{name}}<br/><div class='elementDescription'>Description: {{description}}</div><br/><div class='elementLink>'>Link: <a href='{{link}}' target='_blank'>{{link}}</a></div><br/>{{#image_link}}<div class='description-image'><img src='{{image_link}}'></div>{{/image_link}}Appearances in this interview:<div id='{{type}}InternalReferences'></div><br/>Also mentioned in these interviews<div id='{{type}}ExternalReferences'></div><div class='description-link'><a href='javascript:showList(\"{{type}}\")'>Show {{type}} list</a></div>"}
    };
};

var elements = [];


// augment the database records for a people etc. with their type
// we need this since all elements are eventually put into a single array
//   and we will want to know which are people, which are concepts and which are places
function addType(array, type)
{
    for (var i = 0 ; i < array.length ; i++)
    {
        var currentHash = array[i];
        currentHash.type = type;
    }
};



// populate the people, concepts and places tabs with a list
function initTabs()
{
    initTabsAux("person");
    initTabsAux("concept");
    initTabsAux("place");
};

// add list of elements to corresponding ui tab
function initTabsAux(type)
{
    var elementTemplate = "{{#.}}<a href='javascript:showElement(\"{{name}}\")'>{{name}}</a><br/>{{/.}}";
    var configHash = extraData[type];
    var text = Mustache.render(elementTemplate, configHash.data);
    configHash.listHtml = text;     // save list so we can switch back to it
    jQuery(configHash.divId).html(text);
};

function showElementFromAnnotation(e)
{
    name = $(e.target).data('annotation').tags[0]
    showElement(name);
}

// display the element corresponding to the passed name in the proper tab
// make ajax requests to fetch references to the passed name, both in this pid and for other pids
function showElement(name, forceList)
{
    var element = getElement(name);
    if (element == null)
        return;
    var type = element.type;
    var configHash = extraData[type];
    if (type == "place" && forceList != true)
    {
        highlightMapByName(name);
        showMapCanvas();
    }
    else
    {
        var div = jQuery(configHash.divId);
        var template = configHash.detailTemplate;
        var text = Mustache.render(template, element);
        div.html(text);
        if (type == "place")
            showLocationIndex();
    }

    clearReferences(type);

    var pid = getPidFromUrl();
    jQuery(configHash.tabId).click();     // show the right tab
    // ajax back to server to get where this term appears in this and other interviews
    var url = "/catalog/get_external_references/" + pid + "/" + name;
    jQuery.ajax({type: "GET",
        url: url
    }).done(function(response){showExternalReferences(response, type)});

    url = "/catalog/get_internal_references/" + pid + "/" + name;
    jQuery.ajax({type: "GET",
        url: url
    }).done(function(response){showInternalReferences(response, type)});
};


function clearReferences(type)
{
    var divName = '#' + type + "ExternalReferences";
    var div = jQuery(divName);
    div.html("");
    divName = '#' + type + "InternalReferences";
    div = jQuery(divName);
    div.html("");
}

// process external references from ajax request
function showExternalReferences(response, type)
{
    var referenceTemplate = "{{#.}}{{title}} ({{count}})<br/>{{/.}}";
    var text = Mustache.render(referenceTemplate, response);
    var divName = '#' + type + "ExternalReferences";
    var div = jQuery(divName);
    div.html(text);
}


function showInternalReferencesOld(response, type)
{
    console.log('top of showInternalReferences');
    var referenceTemplate = "{{#.}}{{segmentNumber}}: {{text}}<br/>{{/.}}";
    text = Mustache.render(referenceTemplate, response);
    divName = '#' + type + "InternalReferences";
    div = jQuery(divName);
    div.html(text);
    foo = response;
    console.log('type = ' + type + ', response = ' + response);
}

// process internal references from ajax request
function showInternalReferences(response, type)
{
    var referenceTemplate = "{{#.}}{{#display_time_ssim}}<a class=\"transcript_chunk_link\" href='javascript:jumpPlayerTo({{start_in_milliseconds}})'>{{display_time_ssim}}</a>{{/display_time_ssim}}  <div id='internalReferenceText{{segmentNumber}}' style='height:1.5em; overflow:hidden'>{{text}}</div>" +
        "<a href='javascript:showInternalReferenceMore({{segmentNumber}})'><div id='internalReferenceMore{{segmentNumber}}' class='show-more'>Show more</div></a><br/>{{/.}}";
    text = Mustache.render(referenceTemplate, response);
    divName = '#' + type + "InternalReferences";
    div = jQuery(divName);
    div.html(text);
}

// handle calls to the show more/show less button on internal references
function showInternalReferenceMore(id)
{
    var textElement = jQuery("#internalReferenceText" + id);
    var moreElement = jQuery("#internalReferenceMore" + id);
    if (moreElement.text() == "Show more")
    {
        textElement.css("height", "auto");    // show all the text
        moreElement.text("Show less");
    }
    else
    {
        textElement.css("height", "1.5em");   // show just the first line
        textElement.css("overflow", "hidden");
        moreElement.text("Show more");
    }
}

// show the list of elements based on the passed type: person, concept or place
function showList(type)
{
    var configHash = extraData[type];
    var listHtml = configHash.listHtml;    // get the html list of elements we previously saved
    var div = jQuery(configHash.divId);
    div.html(listHtml);
};


// return the element hash that represents a database row
function getElement(name)
{
    return getItem(name, elements);
};

// should we use a hash rather than this slow iteration
function getItem(name, array)
{
    for (var i = 0 ; i < array.length ; i++)
    {
        var element = array[i];
        if (element.name == name)
            return element;
    }
    return null;
}


// get all the divs holding transcript text and annotate them via a regular expression
function annotateTranscript()
{
    var utterances = jQuery(".transcript_utterance");
    var regex$ = createRegex(elements);
    var regex = new RegExp(regex$, 'g');
    for (var i = 0 ; i < utterances.length ; i++)
    {
        var utterance = utterances[i];
        var originalText = utterance.innerHTML;
        var annotatedText = originalText.replace(regex, "<a href='javascript:showElement(\"$1\")'>$1</a>");
        utterance.innerHTML = annotatedText;
    }

};


// build a regular expression based on passed records
// passed records is an array of hashes for people, places or concepts
function createRegex(records)
{
    var regex =  "\\b(";
    for (var i = 0 ; i < records.length ; i++)
    {
        var element = records[i];
        var name = element.name;
        regex += name;
        regex += "|";
    }
    regex = regex.substr(0, regex.length - 1); // remove last |
    regex += ")\\b";
    return regex;
};

// below is code to deal with the map
// should it be in this file?

var map = null;

function initMap()
{
    var mapOptions = {
        center: new google.maps.LatLng(42., -71.),
        zoom: 7,
        mapTypeId: google.maps.MapTypeId.HYBRID,
        zoomControl: true,
        panControl: true,
        scaleControl: true
    };
    map = new google.maps.Map(document.getElementById("mapCanvas"), mapOptions);

};

// display the list (index) of places, not the map
function showLocationIndex()
{
    jQuery("#mapParent").hide();
    jQuery("#placesParentDiv").show();
};

// display the map, not the list of places
function showMapCanvas()
{
    jQuery("#placesParentDiv").hide();
    jQuery("#mapParent").show();
    //google.maps.event.trigger(map, 'resize');
};


// iterate over global "places" var and create a marker for each
function initMarkers()
{
    var places = extraData.place.data;
    var latlngbounds = new google.maps.LatLngBounds();

    for (var i = 0 ; i < places.length ; i++)
    {
        var place = places[i];
        var latitude = place.latitutde;
        var longitude = place.longitude;
        var name = place.name;
        var position = new google.maps.LatLng(latitude, longitude);
        var marker = new google.maps.Marker({
            position: position,
            map: map,
            title: name});
        latlngbounds.extend(position);
        addListener(marker);
    }

    //center the map around the markers and adjust zoom
    map.setCenter(latlngbounds.getCenter());
    map.fitBounds(latlngbounds);

};

// when user clicks on a map marker, display an info window
function markerClickHandler(marker)
{
    var name = marker.getTitle();
    highlightMapByName(name);
}

// highlight the passed name on the map by displaying an info window
function highlightMapByName(name)
{
    var element = getElement(name);
    if (name == null)
      return;
    var template = "Name: {{name}}<br/>Description: {{description}}<br><a href='javascript:showElement(\"{{name}}\", true)'>More Info</a>";
    var text = Mustache.render(template, element);
    infoWindow = new google.maps.InfoWindow();
    infoWindow.setContent(text);
    infoWindow.setPosition(new google.maps.LatLng(element.latitutde, element.longitude));
   // map.setZoom(locationTypeToZoomLevel(element.location_type));
    infoWindow.open(map);

}

// get the pid from the browser's current url
// is there a better way to obtain it?
function getPidFromUrl()
{
    var path = window.location.pathname;
    var slash = path.lastIndexOf('/');
    if (slash == -1)
      return 'error in getPidFromUrl';
    var pid = path.substr(slash + 1);
    return pid;
}

function addListener(marker)
{
    google.maps.event.addListener(marker, 'click', function (event) {markerClickHandler(marker)});
}

// return an appropriate map zoom level based on the passed type of location (e.g, university, continent)
function locationTypeToZoomLevel(passedLocationType)
{
    var zoomLevel = 7;
    if ((passedLocationType == "continent") || (passedLocationType == "ocean"))
        zoomLevel = 4;
    else if ((passedLocationType == "country"))
        zoomLevel = 5;
    else if ((passedLocationType == "university") || (passedLocationType == "business") || (passedLocationType == "college/university")
|| (passedLocationType == "library")
    || (passedLocationType == "military base")
|| (passedLocationType == "private school"))
    zoomLevel = 15;
else if ((passedLocationType == "residence")|| (passedLocationType == "building/structure")
    || (passedLocationType == "neighborhood") || (passedLocationType == "railway station")
    || (passedLocationType == "church")
    || (passedLocationType == "institution") || (passedLocationType == "hostel") || (passedLocationType == "hospital")
    || (passedLocationType == "bazar/market")
    || (passedLocationType == "museum") || (passedLocationType == "night club") || (passedLocationType == "holy site")
    || (passedLocationType == "government building") || (passedLocationType == "road") || (passedLocationType == "recreation"))
    zoomLevel = 17;
else if ((passedLocationType == "city/town") || (passedLocationType == "capital") || (passedLocationType == "lake"))
    zoomLevel = 11;
else if ((passedLocationType == "region") || (passedLocationType == "state") || (passedLocationType == "island")
    || (passedLocationType == "territory")
    || (passedLocationType == "district"))
    zoomLevel = 6;
    return zoomLevel;
}












