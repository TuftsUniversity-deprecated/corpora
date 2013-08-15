

// after the page is loaded, init variables holding people, concepts and places
//  and annotate the transcript
jQuery(document).ready(initDataAndTabs);


// the functions initPeople, initConcepts and initPlaces are created
//   by code in AnnotationHelper, they create and initialize variables
//   for people, places and concepts
function initDataAndTabs()
{
    initPeople();
    initConcepts();
    initPlaces();
    initTabs();
    annotateTranscript();
};


// populate the people, concepts and places tabs data
function initTabs()
{
    var template = "{{#.}}{{name}}<br/>{{/.}}";

    var peopleDiv = jQuery("#peopleDiv");
    var text = Mustache.render(template, people);
    peopleDiv.html(text);

    var conceptDiv = jQuery("#conceptsDiv");
    text = Mustache.render(template, concepts);
    conceptDiv.html(text);

    var placesDiv = jQuery("#placesDiv");
    text = Mustache.render(template, places);
    placesDiv.html(text);
};


// get all the divs holding transcript text and annotate via a regular expression
function annotateTranscript()
{
    var utterances = jQuery(".transcript_utterance");
    var regex$ = createRegex([people, concepts, places]);
    var regex = new RegExp(regex$, 'g');
    for (var i = 0 ; i < utterances.length ; i++)
    {
        var utterance = utterances[i];
        var originalText = utterance.innerHTML;
        var annotatedText = originalText.replace(regex, "<a href='javascript:alert(\"$1\")'>$1</a>");
        utterance.innerHTML = annotatedText;
    }

};


// build a regular expression based on passed records
// passed records is an array of hashes for people, places or concepts
function createRegex(records)
{
    var regex =  "(";
    for (var i = 0 ; i < records.length ; i++)
    {
        var group = records[i];
        for (var j = 0 ; j < group.length  ; j++)
        {
            var element = group[j];
            var name = element.name;
            regex += name;
            regex += "|";
        }
    }
    regex = regex.substr(0, regex.length - 1); // remove last |
    regex += ")";
    return regex;
};











