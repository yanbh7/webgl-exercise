import { createRouter, createWebHistory } from "vue-router";
import HomeView from "../views/home/home-view.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView,
    },
    {
      path: "/shader-exercise",
      name: "shader-exercise",
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import("../views/shader-views/shader-container.vue"),
    },
  ],
});

export default router;
