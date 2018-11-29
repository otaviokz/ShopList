function toggleSolution() {
    var resolutionDiv = document.getElementById("resolution");
    resolutionDiv.hidden = !resolutionDiv.hidden
    var toggleButton = document.getElementById("toggleButton");
    if(resolutionDiv.hidden) {
      toggleButton.innerHTML = "Show Resolution"
    } else {
      toggleButton.innerHTML = "Hide Resolution"
    }
}
