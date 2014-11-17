var constructDOMElement = function(elementName, attributes, children, moreAttributes) {
  var obj = {};
  var escapeKey = function(key) {
    return (key.charAt(key.length - 1) === '_' ? key.substring(0, key.length - 1) : key);
  }
  var addAttributes = function (attrs) {
    for (key in attrs) {
      if (key !== "instance") {
        obj[key] = attrs[key];
      }
    }
  }
  addAttributes(attributes);
  addAttributes(moreAttributes);
  return React.DOM[elementName](obj, children);
}
var declareReactClass = function(data) {
  return React.createClass({
    render: function() { return data.render(this); }
    , componentWillMount: function () { var t = this; return Fay$$_(function() { data.componentWillMount(t); }) }
    , componentDidMount: function () { var t = this; return Fay$$_(function() { data.componentDidMount(t); }) }
    , componentWillUnmount: function () { var t = this; return Fay$$_(function() { data.componentWillUnmount(t); }) }
    , displayName: data.displayName
    , getInitialState: function() {
      var initialState = Fay$$_(data.getInitialState);
      var object = {};
      for (var key in initialState) {
        if ("instance" !== key) {
          object[key] = Fay$$_(initialState[key]);
        }
      }
      return object;
    }
  });
}
var renderReact = function(component) {
  React.renderComponent (
    component, document.getElementById('main')
  );
}
