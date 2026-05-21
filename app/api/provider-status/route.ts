export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextResponse } from "next/server";
import { getProviderStatus } from "@/lib/guards/providers";

export async function GET() {
  const status = getProviderStatus();

  return NextResponse.json({
    ok: true,
    status,
    disabled: {
      payments: !status.stripe && !status.razorpay,
      stripeCheckout: !status.stripe,
      razorpayOrders: !status.razorpay,
      platformAi: !status.openai,
      connectors: !status.composio
    }
  });
}
