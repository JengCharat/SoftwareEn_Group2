"use client"
import Image from "next/image";
export default function Home() {
  return (
    <main className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-black text-white">
      
      {/* Animated Background Glow */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-[-20%] left-[-10%] w-[500px] h-[500px] bg-purple-600 rounded-full blur-[150px] opacity-40 animate-pulse"></div>
        <div className="absolute bottom-[-20%] right-[-10%] w-[500px] h-[500px] bg-cyan-500 rounded-full blur-[150px] opacity-40 animate-pulse"></div>
      </div>

      {/* Floating Badge */}
      <div className="mb-6 px-6 py-2 rounded-full bg-gradient-to-r from-pink-500 to-purple-600 text-sm font-semibold animate-bounce shadow-lg">
        🚀 NEXT LEVEL START
      </div>

      {/* Main Title */}
      <h1 className="text-6xl md:text-8xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 via-pink-500 to-purple-500 animate-gradient-x drop-shadow-[0_0_25px_rgba(0,255,255,0.8)]">
        sprint1 โย่วๆ
      </h1>

      {/* Subtitle */}
      <p className="mt-6 text-xl text-gray-300 animate-fadeIn">
        Let’s gooooo 🔥🔥🔥
      </p>

      {/* Button */}
      <button className="mt-10 px-10 py-4 text-lg font-bold rounded-2xl bg-gradient-to-r from-cyan-400 to-blue-600 hover:scale-110 hover:rotate-2 transition-all duration-300 shadow-[0_0_30px_rgba(0,255,255,0.7)]">
        START NOW
      </button>

      {/* Extra Animation Styles */}
      <style jsx>{`
        .animate-gradient-x {
          background-size: 300% 300%;
          animation: gradientMove 6s ease infinite;
        }

        @keyframes gradientMove {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }

        .animate-fadeIn {
          animation: fadeIn 2s ease-in-out;
        }

        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </main>
  );
}
