var svgOriginal;
var svgMarkup;
var svgSource;
var svgError;
var svgShowError;
var svgZoom;

function setValue(id, value)
{
  document.getElementById(id).value = value;
}

function setAttr(id, attr, value)
{
  document.getElementById(id).setAttribute(attr, value);
}

function setHTML(id, html)
{
  document.getElementById(id).innerHTML = html;
}

function setText(id, text)
{
  var node = document.createTextNode(text);
  var obj = document.getElementById(id);
  obj.replaceChild(node, obj.firstChild);
}

function getFloat(id)
{
  var n = document.getElementById(id).value;
  return parseFloat(n);
}

function getInt(id)
{
  var n = document.getElementById(id).value;
  return parseInt(n, 10);
}

function getValue(id)
{
  return document.getElementById(id).value;
}


function initElements()
{
  svgOriginal = document.getElementById("svgOriginal");
  // svgMarkup = document.getElementById("svgMarkup");
  svgSource = document.getElementById("svgSource");
  svgError = document.getElementById("svgError");
  svgShowError = document.getElementById("svgShowError");
  svgZoom = document.getElementById('svgZoom');
  if (svgZoom)
  {
    svgZoom.checked = false;
  }
}

function init()
{
  initElements();
  reset();
  alert(document.getElementById("c1"));
}

function reset()
{
  if (svgOriginal && svgSource)
  {
    var original = svgOriginal.innerHTML;
    svgSource.innerHTML = original;
    refresh();
  }
}

function zoom()
{
  var svgElement = document.getElementById("svgOutput").
    getElementsByTagName("svg")[0];
  var w = svgElement.getAttribute("width");
  var h = svgElement.getAttribute("height");
  
  if (svgZoom && svgZoom.checked)
  {
    svgElement.setAttribute("width", w * 2);
    svgElement.setAttribute("height", h * 2);
  }
  else
  {
    svgElement.setAttribute("width", w / 2);
    svgElement.setAttribute("height", h / 2);
  }
}

function showGrid()
{
  var show = document.getElementById("showGrid").checked;
  var grid = document.getElementById("svgGrid");
  grid.style.display = (show) ? "block" : "none";
}

function refresh()
{
  if (svgSource) {
    var source = svgSource.innerHTML;
    var parser = new DOMParser();
    var doc;
    var elements;
    source = source.replace(/<[^>]+?>/g, "");
    source = source.replace(/&lt;/g, "<");
    source = source.replace(/&gt;/g, ">");
    source = source.replace(/&amp;/g, "&");

    // If showing errors, parse as image/svg+xml
    // otherwise, set "parsererror" elements to empty
    if (svgShowError && svgShowError.checked)
    {
      doc = parser.parseFromString(source, "image/svg+xml");
      var ser = new XMLSerializer();
      alert(ser.serializeToString(doc));
      elements = doc.getElementsByTagName("parsererror");
      alert(elements + " " + elements.length);
    }
    else
    {
      elements = [];
    }
    
    if (elements.length > 0)
    {
      var nodeType = elements[0].firstChild.nodeType;
      if (nodeType == 1) // element node
      {
        svgError.innerHTML = elements[0].innerHTML;
      }
      else if (nodeType == 3) // text node
      {
        svgError.innerHTML = elements[0].firstChild.textContent;
      }
      svgError.style.display = "block";
    }
    else
    {
      // now parse again as text/html so it can be
      // inserted into an HTML document.
      doc = parser.parseFromString(source, "text/html");
      elements = doc.getElementsByTagName("svg");
    
      if (elements.length > 0)
      {
        svgError.style.display = "none";
        if (svgOutput.firstChild)
        {
          svgOutput.replaceChild(elements[0], svgOutput.firstChild)
        }
        else
        {
          svgOutput.appendChild(elements[0]);
        }
      }
    }
  }
}

function reanimate()
{
  var svg = document.getElementById("svgOutput").firstChild;
  svg.setCurrentTime(0);
}
/*
 * DOMParser HTML extension
 * 2012-09-04
 * 
 * By Eli Grey, http://eligrey.com
 * Public domain.
 * NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
 */

/*! @source https://gist.github.com/1129031 */
/*global document, DOMParser*/

(function(DOMParser) {
  "use strict";
 
  var
    DOMParser_proto = DOMParser.prototype
  , real_parseFromString = DOMParser_proto.parseFromString
  ;

  // Firefox/Opera/IE throw errors on unsupported types
  try {
    // WebKit returns null on unsupported types
    if ((new DOMParser).parseFromString("", "text/html")) {
      // text/html parsing is natively supported
      return;
    }
  } catch (ex) {}

  DOMParser_proto.parseFromString = function(markup, type) {
    if (/^\s*text\/html\s*(?:;|$)/i.test(type)) {
      var
        doc = document.implementation.createHTMLDocument("")
      ;
            if (markup.toLowerCase().indexOf('<!doctype') > -1) {
              doc.documentElement.innerHTML = markup;
            }
            else {
              doc.body.innerHTML = markup;
            }
      return doc;
    } else {
      return real_parseFromString.apply(this, arguments);
    }
  };
}(DOMParser));
