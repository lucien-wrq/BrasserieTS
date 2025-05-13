import "bootstrap/dist/css/bootstrap.min.css";
import "../styles/custom-bootstrap.scss";
import "../styles/globals.css";
import { SpeedInsights } from "@vercel/speed-insights/next";

export default function MyApp({ Component, pageProps }: any) {
  return (
    <>
      <SpeedInsights />
      <Component {...pageProps} />
    </>
  );
}