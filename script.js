function toggleSidebar() {
  const sidebar = document.getElementById("sidebar");
  const sidebarContent = document.getElementById("sidebar-content");
  const contentSource = document.getElementById("mainpage-content");
  if (sidebar.classList.contains("actived")) {
    sidebar.classList.remove("actived");
  } else {
    sidebarContent.innerHTML = contentSource.innerHTML;
    sidebar.classList.add("actived");
    function closeSidebar(event) {
      if (
        !sidebar.contains(event.target) &&
        event.target.className !== "toggle-btn"
      ) {
        sidebar.classList.remove("actived");
        document.removeEventListener("click", closeSidebar);
      }
    }
    document.addEventListener("click", closeSidebar);
  }
}
document.addEventListener("DOMContentLoaded", function () {
  const sidebarContent = document.getElementById("sidebar-content");
  sidebarContent.addEventListener("click", function (event) {
    if (event.target.tagName.toLowerCase() === "a") {
      toggleSidebar();
    }
  });
});
