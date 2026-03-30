declare module 'nestjs-inertia' {
  import { DynamicModule, MiddlewareConsumer } from '@nestjs/common';
  
  export class InertiaModule {
    static forRoot(options: { rootView: string }): DynamicModule;
  }
  
  export class InertiaMiddleware {
    use(req: any, res: any, next: () => void): void;
  }
  
  export function Inertia(): ParameterDecorator;
}
