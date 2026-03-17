import tailwindcssVite from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: "2025-05-15",
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      // apiBase: "http://localhost:3002/api",
      apiBase: "http://10.198.200.88:3002/api",
      // apiBase:"https://painamnae-backend.onrender.com/api/",
      googleMapsApiKey: "YOUR_GOOGLE_KEY",
    },
  },
  devServer: {
    port: 3002,
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
        {
          rel: "stylesheet",
          href: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css",
        },
      ],
    },
  },
  vite: {
    plugins: [tailwindcssVite()],
  },

  css: ["~/assets/css/input.css"],
  build: {
    transpile: ["leaflet"],
  },
});
