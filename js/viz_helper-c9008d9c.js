var Vizzy = function() {

  var graphs = document.querySelectorAll('script[type="text/graphviz"]');
  for( var i = 0, len = graphs.length; i < len; i++ ) {
    var graph = graphs[i];
    var graphText = Viz(graph.innerHTML, "svg");
    var newGraphNode = document.createElement("div");
    newGraphNode.innerHTML += graphText;
    newGraphNode.style="height:100%;width:100%";
    if (graph.nextSibling) {
      graph.parentNode.insertBefore(newGraphNode, graph.nextSibling);
    } else {
      graph.parentNode.appendChild(newGraphNode);
    }
  }
}
;
