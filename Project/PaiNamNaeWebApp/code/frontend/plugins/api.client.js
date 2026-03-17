import { useCookie } from '#app'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()

  const api = $fetch.create({
    baseURL: config.public.apiBase,
    credentials: 'omit',

    async onRequest({ options }) {
      const token = useCookie('token').value

      options.headers = {
        ...options.headers,
        'ngrok-skip-browser-warning': 'true',
      }

      if (token) {
        options.headers.Authorization = `Bearer ${token}`
      }
    },

    // Handle success response
    onResponse({ response }) {
      const body = response._data

      // unwrap data only if request success
      if (
        response.status < 400 &&
        body &&
        typeof body === 'object' &&
        Object.prototype.hasOwnProperty.call(body, 'data')
      ) {
        response._data = body.data
      }
    },

    // Handle error response
    onResponseError({ response }) {
      let body = response?._data

      if (typeof body === 'string') {
        try {
          body = JSON.parse(body)
        } catch {}
      }

      const msg =
        body?.message ||
        body?.error?.message ||
        body?.error ||
        response?.statusText ||
        'Request failed'

      throw createError({
        statusCode: response?.status || 500,
        statusMessage: msg,
        data: body,
      })
    },
  })

  return {
    provide: {
      api,
    },
  }
})
