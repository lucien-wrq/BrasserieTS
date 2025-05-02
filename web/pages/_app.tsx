import "bootstrap/dist/css/bootstrap.min.css";
import "../styles/custom-bootstrap.scss";
import "../styles/globals.css";

export default function MyApp({ Component, pageProps }: any) {
  return <Component {...pageProps} />;
}