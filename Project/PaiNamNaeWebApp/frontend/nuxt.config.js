import tailwindcssVite from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: "2025-05-15",
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
<<<<<<< HEAD
      apiBase: "http://10.198.200.88:3008/api",
=======
      apiBase: "http://10.198.200.88:3012/api",
>>>>>>> c52d1e1febf39086395f1122ddb52f4292e30dca
      // apiBase:"https://painamnae-backend.onrender.com/api/",
      googleMapsApiKey: "YOUR_GOOGLE_KEY",
    },
  },
  devServer: {
<<<<<<< HEAD
    port: 3009,
=======
    port: 3013,
>>>>>>> c52d1e1febf39086395f1122ddb52f4292e30dca
  },
  plugins: ["~/plugins/api.client.js"],
  app: {
    head: {
      title: "ไปนำแหน่",
      meta: [{ name: "description", content: "รายละเอียด" }],
      charset: "utf-8",
      viewport: "width=device-width, initial-scale=1, maximum-scale=1",
      link: [
        {
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap",
        },
      ],
    },
  },
  vite: {
    plugins: [tailwindcssVite()],
  },

  css: ["leaflet/dist/leaflet.css", "~/assets/css/input.css"],
  build: {
    transpile: ["leaflet"],
  },
});
