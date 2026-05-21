export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextResponse} from "next/server"; import {getProviderStatus} from "@/lib/guards/providers";
export async function GET(){const providers=getProviderStatus(); return NextResponse.json({ok:true,providers,launch_blocks:{openai_missing:!providers.openai,stripe_missing:!providers.stripe,razorpay_missing:!providers.razorpay,composio_missing:!providers.composio,payments_locked:!providers.stripe&&!providers.razorpay,platform_ai_locked:!providers.openai}});}
