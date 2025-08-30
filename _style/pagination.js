let page = 1;
let loading = false;
const observer = new IntersectionObserver(
  async ([entry]) => {
    if (entry.isIntersecting && !loading) {
      loading = true;
      const res = await fetch(`/get-posts?page=${page}`);
      const html = await res.text();
      document.querySelector("#content").insertAdjacentHTML("beforeend", html);
      page++;
      loading = false;
    }
  },
  {
    rootMargin: "200px", // start loading *before* it hits the bottom
  },
);
observer.observe(document.querySelector("#load-more-sentinel"));
