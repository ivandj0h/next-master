import Image from "next/image";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="flex flex-col items-center justify-center">
        <Image
          src="/vercel.svg"
          alt="Vercel Logo"
          width={300}
          height={65}
          className="mb-8"
        />
      </div>
      <h1 className="text-4xl font-bold">NEXTJS STARTER</h1>
    </main>
  );
}
