import { useState, useEffect, useRef } from "react";

const SCREENS = {
  SPLASH: "splash",
  ONBOARDING: "onboarding",
  HOME: "home",
  SEARCH: "search",
  CAR_DETAIL: "carDetail",
  COMPARE: "compare",
  WISHLIST: "wishlist",
  PROFILE: "profile",
};

// ─── Color System ───
const C = {
  bg: "#0A0A0F",
  bgCard: "#141420",
  bgCardHover: "#1A1A2E",
  bgGlass: "rgba(20, 20, 32, 0.72)",
  gold: "#D4A853",
  goldLight: "#F0D78C",
  goldDark: "#A17A2B",
  accent: "#E8B940",
  white: "#FAFAFA",
  textPrimary: "#F0EDE6",
  textSecondary: "#9A9AAE",
  textMuted: "#5E5E72",
  border: "rgba(212, 168, 83, 0.12)",
  borderLight: "rgba(255,255,255,0.06)",
  gradient1: "linear-gradient(135deg, #D4A853 0%, #F0D78C 50%, #D4A853 100%)",
  gradient2: "linear-gradient(180deg, #0A0A0F 0%, #141420 100%)",
  gradient3: "linear-gradient(135deg, #1A1A2E 0%, #0A0A0F 100%)",
  success: "#34D399",
  danger: "#F87171",
  info: "#60A5FA",
};

// ─── Icon Components ───
const Icon = ({ name, size = 20, color = C.textSecondary }) => {
  const icons = {
    search: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
    ),
    home: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
    ),
    heart: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
    ),
    heartFilled: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill={C.danger} stroke={C.danger} strokeWidth="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
    ),
    user: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
    ),
    compare: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 22v-8.3a4 4 0 0 0-1.172-2.872L3 3"/><path d="m15 9 6-6"/></svg>
    ),
    filter: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
    ),
    chevronRight: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><polyline points="9 18 15 12 9 6"/></svg>
    ),
    chevronLeft: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><polyline points="15 18 9 12 15 6"/></svg>
    ),
    star: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill={C.gold} stroke={C.gold} strokeWidth="1"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
    ),
    fuel: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M3 22V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v17"/><path d="M15 10h2a2 2 0 0 1 2 2v2a2 2 0 0 0 2 2 2 2 0 0 0 2-2V9.83a2 2 0 0 0-.59-1.42L18 4"/><path d="M3 22h12"/><path d="M7 9h4"/></svg>
    ),
    speed: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M12 12m-10 0a10 10 0 1 0 20 0"/><path d="M12 12l4-8"/><circle cx="12" cy="12" r="2" fill={color}/></svg>
    ),
    calendar: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
    ),
    location: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
    ),
    bell: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
    ),
    shield: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
    ),
    check: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round"><polyline points="20 6 9 17 4 12"/></svg>
    ),
    car: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>
    ),
    transmission: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><circle cx="6" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="6" r="3"/><circle cx="18" cy="18" r="3"/><path d="M6 9v6"/><path d="M18 9v6"/><path d="M9 6h6"/></svg>
    ),
    camera: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
    ),
    phone: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
    ),
    arrowRight: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
    ),
  };
  return icons[name] || null;
};

// ─── Car Data ───
const CARS = [
  { id: 1, name: "Mercedes-Benz C-Class", year: 2022, price: "32.5L", km: "18,200", fuel: "Petrol", trans: "Automatic", owner: "1st", city: "Mumbai", rating: 4.8, img: "🚗", color: "#C0C0C0", badge: "Premium", emi: "₹48,200/mo" },
  { id: 2, name: "BMW 3 Series", year: 2021, price: "38.9L", km: "22,500", fuel: "Diesel", trans: "Automatic", owner: "1st", city: "Delhi", rating: 4.9, img: "🚗", color: "#1A1A2E", badge: "Luxury", emi: "₹55,400/mo" },
  { id: 3, name: "Audi A4", year: 2023, price: "41.2L", km: "8,400", fuel: "Petrol", trans: "Automatic", owner: "1st", city: "Bangalore", rating: 4.7, img: "🚗", color: "#2D1B1B", badge: "Like New", emi: "₹61,800/mo" },
  { id: 4, name: "Toyota Fortuner", year: 2022, price: "34.8L", km: "28,600", fuel: "Diesel", trans: "Automatic", owner: "1st", city: "Chennai", rating: 4.6, img: "🚙", color: "#1B2D1B", badge: "Popular", emi: "₹50,200/mo" },
  { id: 5, name: "Hyundai Creta", year: 2023, price: "14.5L", km: "12,300", fuel: "Petrol", trans: "Manual", owner: "1st", city: "Pune", rating: 4.5, img: "🚙", color: "#1B1B2D", badge: "Best Value", emi: "₹22,100/mo" },
  { id: 6, name: "Tata Harrier", year: 2023, price: "18.9L", km: "15,800", fuel: "Diesel", trans: "Automatic", owner: "1st", city: "Hyderabad", rating: 4.4, img: "🚙", color: "#2D2D1B", badge: "Trending", emi: "₹28,400/mo" },
  { id: 7, name: "Kia Seltos", year: 2024, price: "16.2L", km: "5,200", fuel: "Petrol", trans: "Automatic", owner: "1st", city: "Mumbai", rating: 4.7, img: "🚙", color: "#1B2D2D", badge: "Almost New", emi: "₹24,600/mo" },
  { id: 8, name: "Mahindra XUV700", year: 2023, price: "22.5L", km: "19,400", fuel: "Diesel", trans: "Automatic", owner: "1st", city: "Delhi", rating: 4.6, img: "🚙", color: "#2D1B2D", badge: "Top Pick", emi: "₹33,800/mo" },
];

const BRANDS = [
  { name: "Mercedes", emoji: "⭐", count: 245 },
  { name: "BMW", emoji: "🔵", count: 198 },
  { name: "Audi", emoji: "🔘", count: 176 },
  { name: "Toyota", emoji: "🔴", count: 412 },
  { name: "Hyundai", emoji: "🅷", count: 389 },
  { name: "Tata", emoji: "🇹", count: 356 },
  { name: "Kia", emoji: "🅺", count: 287 },
  { name: "Mahindra", emoji: "🅼", count: 334 },
];

// ─── Styles ───
const styles = {
  phone: {
    width: 393,
    height: 852,
    borderRadius: 44,
    background: C.bg,
    position: "relative",
    overflow: "hidden",
    fontFamily: "'DM Sans', 'SF Pro Display', -apple-system, sans-serif",
    boxShadow: `0 0 0 2px ${C.border}, 0 50px 100px rgba(0,0,0,0.6), 0 0 120px rgba(212,168,83,0.08)`,
  },
  statusBar: {
    height: 54,
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "0 28px",
    fontSize: 14,
    fontWeight: 600,
    color: C.textPrimary,
    zIndex: 10,
    position: "relative",
  },
  screen: {
    height: "calc(100% - 54px)",
    overflow: "hidden",
    position: "relative",
  },
  navBar: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    height: 84,
    background: "rgba(10, 10, 15, 0.92)",
    backdropFilter: "blur(20px)",
    WebkitBackdropFilter: "blur(20px)",
    borderTop: `1px solid ${C.borderLight}`,
    display: "flex",
    alignItems: "flex-start",
    justifyContent: "space-around",
    paddingTop: 12,
    zIndex: 100,
  },
};

// ─── Splash Screen ───
function SplashScreen({ onDone }) {
  const [phase, setPhase] = useState(0);
  useEffect(() => {
    const t1 = setTimeout(() => setPhase(1), 300);
    const t2 = setTimeout(() => setPhase(2), 1200);
    const t3 = setTimeout(() => setPhase(3), 2000);
    const t4 = setTimeout(onDone, 2800);
    return () => { clearTimeout(t1); clearTimeout(t2); clearTimeout(t3); clearTimeout(t4); };
  }, []);

  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", background: `radial-gradient(ellipse at 50% 40%, rgba(212,168,83,0.08) 0%, ${C.bg} 70%)` }}>
      <style>{`
        @keyframes logoGlow { 0%,100% { filter: drop-shadow(0 0 20px rgba(212,168,83,0.3)); } 50% { filter: drop-shadow(0 0 40px rgba(212,168,83,0.6)); } }
        @keyframes lineExpand { from { width: 0; } to { width: 60px; } }
        @keyframes pulse { 0%,100% { opacity: 0.4; } 50% { opacity: 1; } }
      `}</style>
      {/* Logo Mark */}
      <div style={{
        width: 90, height: 90, borderRadius: 24,
        background: `linear-gradient(145deg, ${C.gold}, ${C.goldDark})`,
        display: "flex", alignItems: "center", justifyContent: "center",
        opacity: phase >= 1 ? 1 : 0,
        transform: phase >= 1 ? "scale(1)" : "scale(0.5)",
        transition: "all 0.8s cubic-bezier(0.16, 1, 0.3, 1)",
        animation: phase >= 1 ? "logoGlow 2s ease-in-out infinite" : "none",
        boxShadow: `0 20px 60px rgba(212,168,83,0.25)`,
      }}>
        <span style={{ fontSize: 36, fontWeight: 800, color: C.bg, letterSpacing: -2 }}>SA</span>
      </div>

      {/* Brand Name */}
      <div style={{
        marginTop: 24,
        opacity: phase >= 2 ? 1 : 0,
        transform: phase >= 2 ? "translateY(0)" : "translateY(20px)",
        transition: "all 0.6s cubic-bezier(0.16, 1, 0.3, 1)",
      }}>
        <span style={{ fontSize: 28, fontWeight: 700, color: C.textPrimary, letterSpacing: 2 }}>SEARCH</span>
        <span style={{ fontSize: 28, fontWeight: 700, color: C.gold, letterSpacing: 2 }}>ANY</span>
        <span style={{ fontSize: 28, fontWeight: 700, color: C.textPrimary, letterSpacing: 2 }}>CARS</span>
      </div>

      {/* Tagline */}
      <div style={{
        marginTop: 8,
        opacity: phase >= 2 ? 1 : 0,
        transition: "all 0.6s ease 0.3s",
        fontSize: 12, letterSpacing: 4, color: C.textSecondary, textTransform: "uppercase",
      }}>
        India's Trusted Platform
      </div>

      {/* Loading Line */}
      <div style={{
        marginTop: 48,
        height: 2,
        background: C.gold,
        borderRadius: 1,
        opacity: phase >= 3 ? 1 : 0,
        animation: phase >= 3 ? "lineExpand 0.8s ease forwards" : "none",
      }} />
    </div>
  );
}

// ─── Onboarding Screen ───
function OnboardingScreen({ onDone }) {
  const [step, setStep] = useState(0);
  const slides = [
    { emoji: "🔍", title: "Discover Your\nDream Car", desc: "Browse 10,000+ verified used cars from trusted dealers across India", color: C.gold },
    { emoji: "🛡️", title: "200-Point\nInspection", desc: "Every car undergoes rigorous quality checks. Buy with complete confidence", color: C.success },
    { emoji: "💰", title: "Best Price\nGuarantee", desc: "Transparent pricing with no hidden charges. Easy EMI options available", color: C.info },
  ];

  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column", background: C.bg }}>
      <style>{`
        @keyframes float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-12px); } }
      `}</style>
      {/* Skip */}
      <div style={{ padding: "20px 24px", textAlign: "right" }}>
        <span onClick={onDone} style={{ fontSize: 14, color: C.textSecondary, cursor: "pointer", letterSpacing: 1 }}>SKIP</span>
      </div>

      {/* Illustration Area */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 32px" }}>
        <div style={{
          width: 160, height: 160, borderRadius: "50%",
          background: `radial-gradient(circle, ${slides[step].color}15, transparent 70%)`,
          display: "flex", alignItems: "center", justifyContent: "center",
          animation: "float 3s ease-in-out infinite",
          border: `1px solid ${slides[step].color}20`,
        }}>
          <span style={{ fontSize: 72 }}>{slides[step].emoji}</span>
        </div>

        <h1 style={{
          fontSize: 32, fontWeight: 800, color: C.textPrimary, textAlign: "center",
          marginTop: 40, lineHeight: 1.2, whiteSpace: "pre-line",
          transition: "all 0.4s ease",
        }}>
          {slides[step].title}
        </h1>

        <p style={{
          fontSize: 16, color: C.textSecondary, textAlign: "center",
          marginTop: 16, lineHeight: 1.6, maxWidth: 280,
        }}>
          {slides[step].desc}
        </p>
      </div>

      {/* Bottom Nav */}
      <div style={{ padding: "0 32px 60px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        {/* Dots */}
        <div style={{ display: "flex", gap: 8 }}>
          {slides.map((_, i) => (
            <div key={i} style={{
              width: i === step ? 24 : 8, height: 8, borderRadius: 4,
              background: i === step ? C.gold : C.textMuted,
              transition: "all 0.3s ease",
            }} />
          ))}
        </div>

        {/* Next Button */}
        <div
          onClick={() => step < 2 ? setStep(step + 1) : onDone()}
          style={{
            width: 60, height: 60, borderRadius: 30,
            background: C.gradient1,
            display: "flex", alignItems: "center", justifyContent: "center",
            cursor: "pointer",
            boxShadow: "0 8px 30px rgba(212,168,83,0.3)",
          }}
        >
          <Icon name="arrowRight" size={24} color={C.bg} />
        </div>
      </div>
    </div>
  );
}

// ─── Home Screen ───
function HomeScreen({ onNavigate, wishlist, toggleWishlist }) {
  const [searchFocused, setSearchFocused] = useState(false);
  const scrollRef = useRef(null);

  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column" }}>
      <style>{`
        @keyframes shimmer { 0% { background-position: -200% center; } 100% { background-position: 200% center; } }
        @keyframes fadeUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .car-card:active { transform: scale(0.97) !important; }
        .brand-chip:active { transform: scale(0.93) !important; }
        .scroll-x::-webkit-scrollbar { display: none; }
      `}</style>

      <div style={{ flex: 1, overflowY: "auto", overflowX: "hidden", paddingBottom: 100 }} className="scroll-x">
        {/* Header */}
        <div style={{ padding: "4px 24px 0" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div>
              <div style={{ fontSize: 13, color: C.textSecondary, letterSpacing: 1 }}>📍 CHENNAI</div>
              <div style={{ fontSize: 22, fontWeight: 700, color: C.textPrimary, marginTop: 2 }}>
                Hello, <span style={{ color: C.gold }}>Karthi</span>
              </div>
            </div>
            <div style={{ display: "flex", gap: 12 }}>
              <div style={{
                width: 42, height: 42, borderRadius: 14,
                background: C.bgCard, border: `1px solid ${C.borderLight}`,
                display: "flex", alignItems: "center", justifyContent: "center",
                position: "relative",
              }}>
                <Icon name="bell" size={18} color={C.textSecondary} />
                <div style={{ position: "absolute", top: 8, right: 8, width: 8, height: 8, borderRadius: 4, background: C.danger }} />
              </div>
              <div style={{
                width: 42, height: 42, borderRadius: 14,
                background: `linear-gradient(135deg, ${C.gold}, ${C.goldDark})`,
                display: "flex", alignItems: "center", justifyContent: "center",
                boxShadow: "0 4px 16px rgba(212,168,83,0.2)",
              }}>
                <span style={{ fontSize: 16, fontWeight: 700, color: C.bg }}>KM</span>
              </div>
            </div>
          </div>
        </div>

        {/* Search Bar */}
        <div style={{ padding: "20px 24px 0" }}>
          <div
            onClick={() => onNavigate(SCREENS.SEARCH)}
            style={{
              height: 56, borderRadius: 18,
              background: C.bgCard,
              border: `1px solid ${C.border}`,
              display: "flex", alignItems: "center", padding: "0 20px", gap: 12,
              cursor: "pointer",
              transition: "all 0.3s ease",
            }}
          >
            <Icon name="search" size={20} color={C.gold} />
            <span style={{ fontSize: 15, color: C.textMuted, flex: 1 }}>Search any car, brand, model...</span>
            <div style={{
              height: 36, width: 36, borderRadius: 12,
              background: `rgba(212,168,83,0.1)`,
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="filter" size={16} color={C.gold} />
            </div>
          </div>
        </div>

        {/* Hero Banner */}
        <div style={{ padding: "20px 24px 0" }}>
          <div style={{
            borderRadius: 24, padding: 24, position: "relative", overflow: "hidden",
            background: `linear-gradient(135deg, #1A1428 0%, #0F1A2E 50%, #0A1520 100%)`,
            border: `1px solid ${C.border}`,
          }}>
            <div style={{
              position: "absolute", top: -20, right: -20, width: 140, height: 140,
              borderRadius: "50%", background: `radial-gradient(circle, rgba(212,168,83,0.12), transparent)`,
            }} />
            <div style={{ fontSize: 11, color: C.gold, letterSpacing: 2, fontWeight: 600 }}>LIMITED TIME OFFER</div>
            <div style={{ fontSize: 24, fontWeight: 800, color: C.textPrimary, marginTop: 8, lineHeight: 1.2 }}>
              Zero Down Payment
            </div>
            <div style={{ fontSize: 14, color: C.textSecondary, marginTop: 6, lineHeight: 1.5 }}>
              Drive home your dream car today. EMI starts at just ₹9,999/mo
            </div>
            <div style={{
              marginTop: 16, display: "inline-flex", alignItems: "center", gap: 8,
              padding: "10px 20px", borderRadius: 12,
              background: C.gradient1, cursor: "pointer",
            }}>
              <span style={{ fontSize: 13, fontWeight: 700, color: C.bg }}>Explore Offers</span>
              <Icon name="arrowRight" size={14} color={C.bg} />
            </div>
            <div style={{ position: "absolute", bottom: 12, right: 20, fontSize: 64, opacity: 0.15 }}>🚗</div>
          </div>
        </div>

        {/* Brands */}
        <div style={{ padding: "24px 0 0" }}>
          <div style={{ padding: "0 24px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <span style={{ fontSize: 18, fontWeight: 700, color: C.textPrimary }}>Popular Brands</span>
            <span style={{ fontSize: 13, color: C.gold, cursor: "pointer" }}>View All</span>
          </div>
          <div style={{ display: "flex", gap: 12, padding: "16px 24px 0", overflowX: "auto" }} className="scroll-x">
            {BRANDS.map((b, i) => (
              <div key={i} className="brand-chip" style={{
                minWidth: 76, padding: "14px 8px", borderRadius: 18,
                background: C.bgCard, border: `1px solid ${C.borderLight}`,
                display: "flex", flexDirection: "column", alignItems: "center", gap: 8,
                cursor: "pointer", transition: "transform 0.2s ease",
              }}>
                <div style={{
                  width: 44, height: 44, borderRadius: 14,
                  background: `rgba(212,168,83,0.06)`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 22,
                }}>{b.emoji}</div>
                <span style={{ fontSize: 11, color: C.textPrimary, fontWeight: 600 }}>{b.name}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Stats */}
        <div style={{ padding: "24px 24px 0", display: "flex", gap: 12 }}>
          {[
            { val: "10K+", label: "Cars Listed", icon: "car" },
            { val: "200+", label: "Dealers", icon: "shield" },
            { val: "4.8★", label: "Rating", icon: "star" },
          ].map((s, i) => (
            <div key={i} style={{
              flex: 1, padding: "16px 12px", borderRadius: 16,
              background: C.bgCard, border: `1px solid ${C.borderLight}`,
              textAlign: "center",
            }}>
              <div style={{ fontSize: 20, fontWeight: 800, color: C.gold }}>{s.val}</div>
              <div style={{ fontSize: 11, color: C.textSecondary, marginTop: 4 }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Featured Cars */}
        <div style={{ padding: "24px 0 0" }}>
          <div style={{ padding: "0 24px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <span style={{ fontSize: 18, fontWeight: 700, color: C.textPrimary }}>Featured Cars</span>
            <span style={{ fontSize: 13, color: C.gold, cursor: "pointer" }}>See All</span>
          </div>
          <div style={{ display: "flex", gap: 16, padding: "16px 24px 0", overflowX: "auto" }} className="scroll-x">
            {CARS.slice(0, 4).map((car, i) => (
              <div
                key={car.id}
                className="car-card"
                onClick={() => onNavigate(SCREENS.CAR_DETAIL, car)}
                style={{
                  minWidth: 220, borderRadius: 20, overflow: "hidden",
                  background: C.bgCard, border: `1px solid ${C.borderLight}`,
                  cursor: "pointer", transition: "transform 0.2s ease",
                  animation: `fadeUp 0.5s ease ${i * 0.1}s both`,
                }}
              >
                {/* Car Image Area */}
                <div style={{
                  height: 130, background: `linear-gradient(135deg, ${car.color}, ${C.bgCard})`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  position: "relative",
                }}>
                  <span style={{ fontSize: 56 }}>{car.img}</span>
                  {/* Badge */}
                  <div style={{
                    position: "absolute", top: 10, left: 10,
                    padding: "4px 10px", borderRadius: 8,
                    background: "rgba(212,168,83,0.15)",
                    backdropFilter: "blur(8px)",
                    fontSize: 10, fontWeight: 700, color: C.gold, letterSpacing: 0.5,
                  }}>{car.badge}</div>
                  {/* Heart */}
                  <div
                    onClick={(e) => { e.stopPropagation(); toggleWishlist(car.id); }}
                    style={{
                      position: "absolute", top: 10, right: 10,
                      width: 32, height: 32, borderRadius: 10,
                      background: "rgba(10,10,15,0.5)",
                      backdropFilter: "blur(8px)",
                      display: "flex", alignItems: "center", justifyContent: "center",
                    }}
                  >
                    <Icon name={wishlist.includes(car.id) ? "heartFilled" : "heart"} size={16} color={wishlist.includes(car.id) ? C.danger : C.textSecondary} />
                  </div>
                </div>
                {/* Info */}
                <div style={{ padding: "14px 16px" }}>
                  <div style={{ fontSize: 14, fontWeight: 700, color: C.textPrimary, lineHeight: 1.3 }}>{car.name}</div>
                  <div style={{ fontSize: 11, color: C.textSecondary, marginTop: 4 }}>
                    {car.year} • {car.km} km • {car.fuel}
                  </div>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 10 }}>
                    <span style={{ fontSize: 18, fontWeight: 800, color: C.gold }}>₹{car.price}</span>
                    <span style={{ fontSize: 10, color: C.textMuted }}>{car.emi}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recently Added (Vertical List) */}
        <div style={{ padding: "24px 24px 0" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
            <span style={{ fontSize: 18, fontWeight: 700, color: C.textPrimary }}>Recently Added</span>
            <span style={{ fontSize: 13, color: C.gold, cursor: "pointer" }}>View All</span>
          </div>
          {CARS.slice(4, 8).map((car, i) => (
            <div
              key={car.id}
              className="car-card"
              onClick={() => onNavigate(SCREENS.CAR_DETAIL, car)}
              style={{
                display: "flex", gap: 14, padding: 14, borderRadius: 18,
                background: C.bgCard, border: `1px solid ${C.borderLight}`,
                marginBottom: 12, cursor: "pointer",
                transition: "transform 0.2s ease",
                animation: `fadeUp 0.5s ease ${i * 0.08}s both`,
              }}
            >
              <div style={{
                width: 100, height: 80, borderRadius: 14, flexShrink: 0,
                background: `linear-gradient(135deg, ${car.color}, ${C.bgCard})`,
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <span style={{ fontSize: 40 }}>{car.img}</span>
              </div>
              <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                <div>
                  <div style={{ fontSize: 14, fontWeight: 700, color: C.textPrimary }}>{car.name}</div>
                  <div style={{ fontSize: 11, color: C.textSecondary, marginTop: 2 }}>{car.year} • {car.km} km • {car.trans}</div>
                </div>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <span style={{ fontSize: 16, fontWeight: 800, color: C.gold }}>₹{car.price}</span>
                  <div style={{
                    padding: "3px 8px", borderRadius: 6,
                    background: `rgba(212,168,83,0.1)`,
                    fontSize: 10, color: C.gold, fontWeight: 600,
                  }}>{car.badge}</div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Trust Section */}
        <div style={{ padding: "12px 24px 20px" }}>
          <div style={{
            padding: 20, borderRadius: 20,
            background: `linear-gradient(135deg, rgba(212,168,83,0.06), transparent)`,
            border: `1px solid ${C.border}`,
          }}>
            <div style={{ fontSize: 16, fontWeight: 700, color: C.textPrimary, marginBottom: 14 }}>Why SearchAnyCars?</div>
            {[
              { icon: "shield", text: "200-Point Quality Inspection" },
              { icon: "check", text: "5-Day Money Back Guarantee" },
              { icon: "car", text: "Free Home Test Drive" },
              { icon: "phone", text: "24/7 Customer Support" },
            ].map((item, i) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: i < 3 ? 12 : 0 }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 10,
                  background: "rgba(212,168,83,0.1)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  <Icon name={item.icon} size={16} color={C.gold} />
                </div>
                <span style={{ fontSize: 13, color: C.textSecondary }}>{item.text}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Car Detail Screen ───
function CarDetailScreen({ car, onBack, wishlist, toggleWishlist }) {
  const [activeImg, setActiveImg] = useState(0);
  if (!car) return null;

  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column", background: C.bg }}>
      <style>{`
        .detail-scroll::-webkit-scrollbar { display: none; }
        @keyframes slideUp { from { opacity:0; transform:translateY(30px); } to { opacity:1; transform:translateY(0); } }
      `}</style>
      <div style={{ flex: 1, overflowY: "auto", paddingBottom: 100 }} className="detail-scroll">
        {/* Image Gallery */}
        <div style={{
          height: 300, position: "relative",
          background: `linear-gradient(180deg, ${car.color} 0%, ${C.bg} 100%)`,
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <span style={{ fontSize: 120 }}>{car.img}</span>

          {/* Back Button */}
          <div onClick={onBack} style={{
            position: "absolute", top: 10, left: 20,
            width: 40, height: 40, borderRadius: 14,
            background: "rgba(10,10,15,0.5)", backdropFilter: "blur(10px)",
            display: "flex", alignItems: "center", justifyContent: "center",
            cursor: "pointer",
          }}>
            <Icon name="chevronLeft" size={20} color={C.textPrimary} />
          </div>

          {/* Share & Wishlist */}
          <div style={{ position: "absolute", top: 10, right: 20, display: "flex", gap: 10 }}>
            <div onClick={() => toggleWishlist(car.id)} style={{
              width: 40, height: 40, borderRadius: 14,
              background: "rgba(10,10,15,0.5)", backdropFilter: "blur(10px)",
              display: "flex", alignItems: "center", justifyContent: "center",
              cursor: "pointer",
            }}>
              <Icon name={wishlist.includes(car.id) ? "heartFilled" : "heart"} size={18} color={wishlist.includes(car.id) ? C.danger : C.textPrimary} />
            </div>
          </div>

          {/* Image Dots */}
          <div style={{ position: "absolute", bottom: 16, display: "flex", gap: 6 }}>
            {[0, 1, 2, 3, 4].map(i => (
              <div key={i} onClick={() => setActiveImg(i)} style={{
                width: i === activeImg ? 20 : 6, height: 6, borderRadius: 3,
                background: i === activeImg ? C.gold : "rgba(255,255,255,0.3)",
                transition: "all 0.3s ease", cursor: "pointer",
              }} />
            ))}
          </div>

          {/* Photo Count */}
          <div style={{
            position: "absolute", bottom: 16, right: 20,
            padding: "4px 10px", borderRadius: 8,
            background: "rgba(10,10,15,0.6)", backdropFilter: "blur(8px)",
            display: "flex", alignItems: "center", gap: 4,
          }}>
            <Icon name="camera" size={12} color={C.textSecondary} />
            <span style={{ fontSize: 11, color: C.textSecondary }}>32 Photos</span>
          </div>
        </div>

        {/* Content */}
        <div style={{ padding: "20px 24px", animation: "slideUp 0.5s ease" }}>
          {/* Title & Price */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
            <div style={{ flex: 1 }}>
              <div style={{
                display: "inline-block", padding: "4px 10px", borderRadius: 8,
                background: "rgba(52,211,153,0.1)",
                fontSize: 11, fontWeight: 700, color: C.success, marginBottom: 8,
              }}>✓ Certified</div>
              <div style={{ fontSize: 22, fontWeight: 800, color: C.textPrimary, lineHeight: 1.2 }}>{car.name}</div>
              <div style={{ fontSize: 13, color: C.textSecondary, marginTop: 4 }}>{car.year} Model • {car.owner} Owner</div>
            </div>
          </div>

          {/* Price Card */}
          <div style={{
            marginTop: 20, padding: 20, borderRadius: 20,
            background: `linear-gradient(135deg, rgba(212,168,83,0.08), rgba(212,168,83,0.02))`,
            border: `1px solid ${C.border}`,
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <div style={{ fontSize: 11, color: C.textSecondary, letterSpacing: 1 }}>ASKING PRICE</div>
                <div style={{ fontSize: 32, fontWeight: 800, color: C.gold, marginTop: 4 }}>₹{car.price}</div>
              </div>
              <div style={{ textAlign: "right" }}>
                <div style={{ fontSize: 11, color: C.textSecondary }}>EMI from</div>
                <div style={{ fontSize: 16, fontWeight: 700, color: C.textPrimary, marginTop: 2 }}>{car.emi}</div>
              </div>
            </div>
          </div>

          {/* Quick Specs */}
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10, marginTop: 20 }}>
            {[
              { icon: "speed", label: "Driven", value: car.km + " km" },
              { icon: "fuel", label: "Fuel", value: car.fuel },
              { icon: "transmission", label: "Trans.", value: car.trans },
              { icon: "calendar", label: "Year", value: String(car.year) },
              { icon: "user", label: "Owner", value: car.owner },
              { icon: "location", label: "City", value: car.city },
            ].map((spec, i) => (
              <div key={i} style={{
                padding: "14px 10px", borderRadius: 16, textAlign: "center",
                background: C.bgCard, border: `1px solid ${C.borderLight}`,
              }}>
                <Icon name={spec.icon} size={18} color={C.gold} />
                <div style={{ fontSize: 13, fontWeight: 700, color: C.textPrimary, marginTop: 6 }}>{spec.value}</div>
                <div style={{ fontSize: 10, color: C.textMuted, marginTop: 2 }}>{spec.label}</div>
              </div>
            ))}
          </div>

          {/* Inspection Score */}
          <div style={{
            marginTop: 20, padding: 20, borderRadius: 20,
            background: C.bgCard, border: `1px solid ${C.borderLight}`,
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <div style={{ fontSize: 15, fontWeight: 700, color: C.textPrimary }}>Inspection Report</div>
                <div style={{ fontSize: 12, color: C.textSecondary, marginTop: 4 }}>200-point verified • Passed</div>
              </div>
              <div style={{
                width: 56, height: 56, borderRadius: 16,
                background: "rgba(52,211,153,0.1)", border: `2px solid ${C.success}`,
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <span style={{ fontSize: 18, fontWeight: 800, color: C.success }}>{car.rating}</span>
              </div>
            </div>
            {/* Progress Bars */}
            <div style={{ marginTop: 16 }}>
              {[
                { label: "Engine & Transmission", score: 95 },
                { label: "Exterior & Body", score: 88 },
                { label: "Interior & Electronics", score: 92 },
                { label: "Tyres & Suspension", score: 85 },
              ].map((item, i) => (
                <div key={i} style={{ marginBottom: i < 3 ? 10 : 0 }}>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                    <span style={{ fontSize: 12, color: C.textSecondary }}>{item.label}</span>
                    <span style={{ fontSize: 12, fontWeight: 700, color: C.success }}>{item.score}%</span>
                  </div>
                  <div style={{ height: 4, borderRadius: 2, background: C.borderLight }}>
                    <div style={{
                      height: "100%", borderRadius: 2, width: `${item.score}%`,
                      background: `linear-gradient(90deg, ${C.success}, #6EE7B7)`,
                    }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Dealer Info */}
          <div style={{
            marginTop: 20, padding: 20, borderRadius: 20,
            background: C.bgCard, border: `1px solid ${C.borderLight}`,
            display: "flex", alignItems: "center", gap: 14,
          }}>
            <div style={{
              width: 48, height: 48, borderRadius: 14,
              background: `linear-gradient(135deg, ${C.gold}, ${C.goldDark})`,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 20, fontWeight: 800, color: C.bg,
            }}>P</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: C.textPrimary }}>Premium Auto Hub</div>
              <div style={{ fontSize: 12, color: C.textSecondary }}>⭐ 4.9 • Trusted Dealer • {car.city}</div>
            </div>
            <Icon name="chevronRight" size={20} color={C.textSecondary} />
          </div>
        </div>
      </div>

      {/* Bottom CTA */}
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        padding: "16px 24px 32px",
        background: "linear-gradient(180deg, transparent, rgba(10,10,15,0.95) 30%)",
        display: "flex", gap: 12,
      }}>
        <div style={{
          width: 56, height: 56, borderRadius: 18,
          background: C.bgCard, border: `1px solid ${C.border}`,
          display: "flex", alignItems: "center", justifyContent: "center",
          cursor: "pointer",
        }}>
          <Icon name="phone" size={22} color={C.gold} />
        </div>
        <div style={{
          flex: 1, height: 56, borderRadius: 18,
          background: C.gradient1,
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          cursor: "pointer",
          boxShadow: "0 8px 30px rgba(212,168,83,0.3)",
        }}>
          <span style={{ fontSize: 16, fontWeight: 700, color: C.bg }}>Book Test Drive</span>
        </div>
      </div>
    </div>
  );
}

// ─── Search Screen ───
function SearchScreen({ onNavigate, onBack }) {
  const [query, setQuery] = useState("");
  const [activeFilter, setActiveFilter] = useState("All");
  const filters = ["All", "SUV", "Sedan", "Hatchback", "Luxury", "EV"];
  const filtered = CARS.filter(c => c.name.toLowerCase().includes(query.toLowerCase()));

  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column" }}>
      <style>{`.search-scroll::-webkit-scrollbar{display:none} .filter-chip:active{transform:scale(0.93)!important}`}</style>
      {/* Search Header */}
      <div style={{ padding: "8px 24px 0" }}>
        <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
          <div onClick={onBack} style={{ cursor: "pointer" }}>
            <Icon name="chevronLeft" size={24} color={C.textPrimary} />
          </div>
          <div style={{
            flex: 1, height: 48, borderRadius: 16,
            background: C.bgCard, border: `1px solid ${C.border}`,
            display: "flex", alignItems: "center", padding: "0 16px", gap: 10,
          }}>
            <Icon name="search" size={18} color={C.gold} />
            <input
              value={query}
              onChange={e => setQuery(e.target.value)}
              placeholder="Search cars..."
              style={{
                flex: 1, background: "none", border: "none", outline: "none",
                color: C.textPrimary, fontSize: 14, fontFamily: "inherit",
              }}
            />
          </div>
        </div>

        {/* Filter Chips */}
        <div style={{ display: "flex", gap: 8, marginTop: 16, overflowX: "auto", paddingBottom: 4 }} className="search-scroll">
          {filters.map(f => (
            <div key={f} className="filter-chip" onClick={() => setActiveFilter(f)} style={{
              padding: "8px 18px", borderRadius: 12,
              background: activeFilter === f ? C.gold : C.bgCard,
              border: `1px solid ${activeFilter === f ? C.gold : C.borderLight}`,
              fontSize: 13, fontWeight: 600,
              color: activeFilter === f ? C.bg : C.textSecondary,
              cursor: "pointer", transition: "all 0.2s ease", whiteSpace: "nowrap",
            }}>{f}</div>
          ))}
        </div>
      </div>

      {/* Results */}
      <div style={{ flex: 1, overflowY: "auto", padding: "16px 24px", paddingBottom: 100 }} className="search-scroll">
        <div style={{ fontSize: 12, color: C.textMuted, marginBottom: 12 }}>{filtered.length} cars found</div>
        {filtered.map((car, i) => (
          <div key={car.id} onClick={() => onNavigate(SCREENS.CAR_DETAIL, car)} style={{
            display: "flex", gap: 14, padding: 14, borderRadius: 18,
            background: C.bgCard, border: `1px solid ${C.borderLight}`,
            marginBottom: 12, cursor: "pointer",
          }}>
            <div style={{
              width: 110, height: 85, borderRadius: 14, flexShrink: 0,
              background: `linear-gradient(135deg, ${car.color}, ${C.bgCard})`,
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <span style={{ fontSize: 44 }}>{car.img}</span>
            </div>
            <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
              <div>
                <div style={{ fontSize: 14, fontWeight: 700, color: C.textPrimary }}>{car.name}</div>
                <div style={{ fontSize: 11, color: C.textSecondary, marginTop: 3 }}>
                  {car.year} • {car.km} km • {car.fuel} • {car.trans}
                </div>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <span style={{ fontSize: 17, fontWeight: 800, color: C.gold }}>₹{car.price}</span>
                <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
                  <Icon name="location" size={12} color={C.textMuted} />
                  <span style={{ fontSize: 11, color: C.textMuted }}>{car.city}</span>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Wishlist Screen ───
function WishlistScreen({ onNavigate, wishlist, toggleWishlist }) {
  const wishCars = CARS.filter(c => wishlist.includes(c.id));
  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column" }}>
      <style>{`.wish-scroll::-webkit-scrollbar{display:none}`}</style>
      <div style={{ padding: "8px 24px 0" }}>
        <div style={{ fontSize: 24, fontWeight: 800, color: C.textPrimary }}>Wishlist</div>
        <div style={{ fontSize: 13, color: C.textSecondary, marginTop: 4 }}>{wishCars.length} saved cars</div>
      </div>

      <div style={{ flex: 1, overflowY: "auto", padding: "20px 24px", paddingBottom: 100 }} className="wish-scroll">
        {wishCars.length === 0 ? (
          <div style={{ textAlign: "center", paddingTop: 80 }}>
            <div style={{ fontSize: 64, marginBottom: 16 }}>💛</div>
            <div style={{ fontSize: 18, fontWeight: 700, color: C.textPrimary }}>No saved cars yet</div>
            <div style={{ fontSize: 14, color: C.textSecondary, marginTop: 8 }}>
              Tap the heart icon on cars you love
            </div>
          </div>
        ) : (
          wishCars.map(car => (
            <div key={car.id} onClick={() => onNavigate(SCREENS.CAR_DETAIL, car)} style={{
              display: "flex", gap: 14, padding: 14, borderRadius: 18,
              background: C.bgCard, border: `1px solid ${C.borderLight}`,
              marginBottom: 12, cursor: "pointer", position: "relative",
            }}>
              <div style={{
                width: 110, height: 85, borderRadius: 14, flexShrink: 0,
                background: `linear-gradient(135deg, ${car.color}, ${C.bgCard})`,
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <span style={{ fontSize: 44 }}>{car.img}</span>
              </div>
              <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                <div>
                  <div style={{ fontSize: 14, fontWeight: 700, color: C.textPrimary }}>{car.name}</div>
                  <div style={{ fontSize: 11, color: C.textSecondary, marginTop: 3 }}>{car.year} • {car.km} km</div>
                </div>
                <span style={{ fontSize: 17, fontWeight: 800, color: C.gold }}>₹{car.price}</span>
              </div>
              <div onClick={(e) => { e.stopPropagation(); toggleWishlist(car.id); }}
                style={{ position: "absolute", top: 14, right: 14, cursor: "pointer" }}>
                <Icon name="heartFilled" size={20} />
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

// ─── Profile Screen ───
function ProfileScreen() {
  const menuItems = [
    { icon: "car", label: "My Bookings", count: 2 },
    { icon: "heart", label: "Saved Cars", count: 5 },
    { icon: "compare", label: "Compare History" },
    { icon: "shield", label: "Insurance & Warranty" },
    { icon: "phone", label: "Support Center" },
    { icon: "bell", label: "Notifications", count: 3 },
  ];

  return (
    <div style={{ ...styles.screen, display: "flex", flexDirection: "column" }}>
      <style>{`.prof-scroll::-webkit-scrollbar{display:none}`}</style>
      <div style={{ flex: 1, overflowY: "auto", paddingBottom: 100 }} className="prof-scroll">
        {/* Profile Header */}
        <div style={{
          padding: "20px 24px 30px", textAlign: "center",
          background: `radial-gradient(ellipse at 50% 0%, rgba(212,168,83,0.08), transparent 70%)`,
        }}>
          <div style={{
            width: 80, height: 80, borderRadius: 24, margin: "0 auto",
            background: `linear-gradient(135deg, ${C.gold}, ${C.goldDark})`,
            display: "flex", alignItems: "center", justifyContent: "center",
            boxShadow: "0 12px 40px rgba(212,168,83,0.25)",
          }}>
            <span style={{ fontSize: 28, fontWeight: 800, color: C.bg }}>KM</span>
          </div>
          <div style={{ fontSize: 20, fontWeight: 700, color: C.textPrimary, marginTop: 16 }}>Karthi M</div>
          <div style={{ fontSize: 13, color: C.textSecondary, marginTop: 4 }}>Member since 2024</div>
          <div style={{
            display: "inline-flex", alignItems: "center", gap: 6,
            padding: "6px 14px", borderRadius: 10, marginTop: 12,
            background: "rgba(212,168,83,0.1)", border: `1px solid ${C.border}`,
          }}>
            <Icon name="star" size={14} />
            <span style={{ fontSize: 12, fontWeight: 600, color: C.gold }}>Gold Member</span>
          </div>
        </div>

        {/* Menu */}
        <div style={{ padding: "0 24px" }}>
          {menuItems.map((item, i) => (
            <div key={i} style={{
              display: "flex", alignItems: "center", gap: 14,
              padding: "16px 0",
              borderBottom: i < menuItems.length - 1 ? `1px solid ${C.borderLight}` : "none",
              cursor: "pointer",
            }}>
              <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: C.bgCard,
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <Icon name={item.icon} size={18} color={C.gold} />
              </div>
              <span style={{ flex: 1, fontSize: 15, color: C.textPrimary, fontWeight: 500 }}>{item.label}</span>
              {item.count && (
                <span style={{
                  padding: "2px 8px", borderRadius: 8,
                  background: "rgba(212,168,83,0.1)",
                  fontSize: 12, fontWeight: 700, color: C.gold,
                }}>{item.count}</span>
              )}
              <Icon name="chevronRight" size={18} color={C.textMuted} />
            </div>
          ))}
        </div>

        {/* App Version */}
        <div style={{ textAlign: "center", padding: "30px 0", color: C.textMuted, fontSize: 12 }}>
          SearchAnyCars v1.0.0
        </div>
      </div>
    </div>
  );
}

// ─── Bottom Nav ───
function BottomNav({ active, onNav }) {
  const items = [
    { id: SCREENS.HOME, icon: "home", label: "Home" },
    { id: SCREENS.SEARCH, icon: "search", label: "Search" },
    { id: SCREENS.COMPARE, icon: "compare", label: "Compare" },
    { id: SCREENS.WISHLIST, icon: "heart", label: "Saved" },
    { id: SCREENS.PROFILE, icon: "user", label: "Profile" },
  ];

  return (
    <div style={styles.navBar}>
      {items.map(item => {
        const isActive = active === item.id;
        return (
          <div key={item.id} onClick={() => onNav(item.id)} style={{
            display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
            cursor: "pointer", minWidth: 56,
            transition: "all 0.2s ease",
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 12,
              background: isActive ? "rgba(212,168,83,0.12)" : "transparent",
              display: "flex", alignItems: "center", justifyContent: "center",
              transition: "all 0.2s ease",
            }}>
              <Icon name={item.icon} size={20} color={isActive ? C.gold : C.textMuted} />
            </div>
            <span style={{
              fontSize: 10, fontWeight: isActive ? 700 : 500,
              color: isActive ? C.gold : C.textMuted,
              transition: "all 0.2s ease",
            }}>{item.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ─── Main App ───
export default function SearchAnyCarsApp() {
  const [screen, setScreen] = useState(SCREENS.SPLASH);
  const [selectedCar, setSelectedCar] = useState(null);
  const [wishlist, setWishlist] = useState([1, 3]);
  const [navScreen, setNavScreen] = useState(SCREENS.HOME);

  const toggleWishlist = (id) => {
    setWishlist(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]);
  };

  const navigate = (dest, data) => {
    if (data) setSelectedCar(data);
    setScreen(dest);
    if ([SCREENS.HOME, SCREENS.SEARCH, SCREENS.COMPARE, SCREENS.WISHLIST, SCREENS.PROFILE].includes(dest)) {
      setNavScreen(dest);
    }
  };

  const showNav = ![SCREENS.SPLASH, SCREENS.ONBOARDING, SCREENS.CAR_DETAIL].includes(screen);

  return (
    <div style={{
      display: "flex", alignItems: "center", justifyContent: "center",
      minHeight: "100vh",
      background: `radial-gradient(ellipse at 30% 20%, rgba(212,168,83,0.04), #060608 60%)`,
      fontFamily: "'DM Sans', sans-serif",
      padding: 20,
    }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,500;0,9..40,700;0,9..40,800&display=swap" rel="stylesheet" />

      {/* Phone Frame */}
      <div style={styles.phone}>
        {/* Status Bar */}
        {screen !== SCREENS.SPLASH && (
          <div style={styles.statusBar}>
            <span>9:41</span>
            <div style={{ display: "flex", gap: 5, alignItems: "center" }}>
              <svg width="16" height="12" viewBox="0 0 16 12"><path d="M1 8h2v4H1zM5 5h2v7H5zM9 3h2v9H9zM13 0h2v12h-2z" fill={C.textPrimary}/></svg>
              <svg width="15" height="12" viewBox="0 0 15 12"><path d="M7.5 3.6C5.7 3.6 4 4.3 2.8 5.5l-1.4-1.4C3 2.5 5.2 1.6 7.5 1.6s4.5.9 6.1 2.5l-1.4 1.4C10.9 4.3 9.3 3.6 7.5 3.6zm0 4C6.7 7.6 6 7.9 5.4 8.5L7.5 11l2.1-2.5C9 7.9 8.3 7.6 7.5 7.6z" fill={C.textPrimary}/></svg>
              <svg width="25" height="12" viewBox="0 0 25 12"><rect x="0" y="1" width="22" height="10" rx="2" stroke={C.textPrimary} strokeWidth="1" fill="none"/><rect x="23" y="4" width="2" height="4" rx="0.5" fill={C.textPrimary}/><rect x="2" y="3" width="14" height="6" rx="1" fill={C.gold}/></svg>
            </div>
          </div>
        )}

        {/* Screen Content */}
        {screen === SCREENS.SPLASH && <SplashScreen onDone={() => setScreen(SCREENS.ONBOARDING)} />}
        {screen === SCREENS.ONBOARDING && <OnboardingScreen onDone={() => { setScreen(SCREENS.HOME); setNavScreen(SCREENS.HOME); }} />}
        {screen === SCREENS.HOME && <HomeScreen onNavigate={navigate} wishlist={wishlist} toggleWishlist={toggleWishlist} />}
        {screen === SCREENS.SEARCH && <SearchScreen onNavigate={navigate} onBack={() => navigate(SCREENS.HOME)} />}
        {screen === SCREENS.CAR_DETAIL && <CarDetailScreen car={selectedCar} onBack={() => navigate(navScreen)} wishlist={wishlist} toggleWishlist={toggleWishlist} />}
        {screen === SCREENS.WISHLIST && <WishlistScreen onNavigate={navigate} wishlist={wishlist} toggleWishlist={toggleWishlist} />}
        {screen === SCREENS.PROFILE && <ProfileScreen />}
        {screen === SCREENS.COMPARE && (
          <div style={{ ...styles.screen, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontSize: 56, marginBottom: 16 }}>⚖️</span>
            <span style={{ fontSize: 20, fontWeight: 700, color: C.textPrimary }}>Compare Cars</span>
            <span style={{ fontSize: 14, color: C.textSecondary, marginTop: 8, textAlign: "center", padding: "0 40px" }}>
              Select 2-3 cars to compare specs, prices, and features side by side
            </span>
            <div style={{
              marginTop: 24, padding: "12px 28px", borderRadius: 14,
              background: C.gradient1, cursor: "pointer",
            }}>
              <span style={{ fontSize: 14, fontWeight: 700, color: C.bg }}>Choose Cars</span>
            </div>
          </div>
        )}

        {/* Bottom Navigation */}
        {showNav && <BottomNav active={navScreen} onNav={(id) => navigate(id)} />}
      </div>
    </div>
  );
}
