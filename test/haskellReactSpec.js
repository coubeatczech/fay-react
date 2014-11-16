describe("Haskell React", function() {
  it("the click event works", function() {
    var singleElement = Fay$$_(HaskellReactSpec.singleElement, true);
    var ReactTestUtils = React.addons.TestUtils;
    var rendered = ReactTestUtils.renderIntoDocument(singleElement).getDOMNode();
    expect(rendered.innerText).toEqual("The header 0");
    ReactTestUtils.Simulate.click(rendered);
    ReactTestUtils.Simulate.click(rendered);
    expect(rendered.innerText).toEqual("The header 2");
  });
  it("component correctly displays isMounted", function () {
    var component = Fay$$_(HaskellReactSpec.element, true);
    var ReactTestUtils = React.addons.TestUtils;
    var rendered = ReactTestUtils.renderIntoDocument(component).getDOMNode();
    expect(rendered.innerText).toEqual("false");
  });
  it("dom node", function () {
    var component = Fay$$_(HaskellReactSpec.aElement, true);
    var ReactTestUtils = React.addons.TestUtils;
    var rendered = ReactTestUtils.renderIntoDocument(component).getDOMNode();
    expect(rendered.innerText).toEqual("Google");
    expect(rendered.getAttribute("href")).toEqual("http://google.com");
  });
  it("can link two elements", function () {
    var component = Fay$$_(HaskellReactSpec.relatedElements, true);
    var ReactTestUtils = React.addons.TestUtils;
    var rendered = ReactTestUtils.renderIntoDocument(component);
    var input = ReactTestUtils.findRenderedDOMComponentWithTag(rendered, "input");
    ReactTestUtils.Simulate.change(input.getDOMNode(), { target: { value: 'abcde' } });
    var span = ReactTestUtils.findRenderedDOMComponentWithTag(rendered, "span");
    expect(span.getDOMNode().innerText).toEqual("Num: 5");
  });
});
