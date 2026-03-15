import type { ComputedRef, MaybeRef } from 'vue'

type ComponentProps<T> = T extends new(...args: any) => { $props: infer P } ? NonNullable<P>
  : T extends (props: infer P, ...args: any) => any ? P
  : {}

declare module 'nuxt/app' {
  interface NuxtLayouts {
    default: ComponentProps<typeof import("/home/tung/SoftwareEn_Group2/Project/PaiNamNaeWebApp/frontend/layouts/default.vue").default>,
    "default-v1": ComponentProps<typeof import("/home/tung/SoftwareEn_Group2/Project/PaiNamNaeWebApp/frontend/layouts/default_v1.vue").default>,
}
  export type LayoutKey = keyof NuxtLayouts extends never ? string : keyof NuxtLayouts
  interface PageMeta {
    layout?: MaybeRef<LayoutKey | false> | ComputedRef<LayoutKey | false>
  }
}