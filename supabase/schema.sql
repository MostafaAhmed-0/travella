-- ==============================================================================
-- TRAVELLA TOUR & TRAVEL — SUPABASE POSTGRESQL SCHEMA & RLS POLICIES
-- ==============================================================================

-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── 1. PROFILES TABLE ─────────────────────────────────────────────────────────
-- Linked to Supabase auth.users
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('admin', 'staff')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 2. DESTINATIONS TABLE ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.destinations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_ar TEXT,
    description TEXT,
    description_ar TEXT,
    country TEXT NOT NULL,
    image_url TEXT,
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3. TOURS TABLE ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    title_ar TEXT,
    description TEXT,
    description_ar TEXT,
    destination_id UUID REFERENCES public.destinations(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('domestic', 'international', 'hajj', 'umrah')),
    duration TEXT NOT NULL,
    price NUMERIC NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'USD',
    image_url TEXT,
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 4. TOUR IMAGES TABLE ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tour_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tour_id UUID NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- ── 5. HOTELS TABLE ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.hotels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_ar TEXT,
    description TEXT,
    location TEXT NOT NULL,
    rating NUMERIC NOT NULL DEFAULT 5.0,
    price NUMERIC NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'USD',
    image_url TEXT,
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 6. VISA SERVICES TABLE ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.visa_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country TEXT NOT NULL,
    country_ar TEXT,
    visa_type TEXT NOT NULL,
    description TEXT,
    description_ar TEXT,
    processing_time TEXT NOT NULL,
    price NUMERIC NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 7. VISA REQUIREMENTS TABLE ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.visa_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visa_service_id UUID NOT NULL REFERENCES public.visa_services(id) ON DELETE CASCADE,
    requirement TEXT NOT NULL,
    requirement_ar TEXT
);

-- ── 8. BOOKINGS TABLE ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    tour_id UUID REFERENCES public.tours(id) ON DELETE SET NULL,
    travel_date DATE,
    travelers INTEGER NOT NULL DEFAULT 1,
    adults_count INTEGER NOT NULL DEFAULT 1 CHECK (adults_count >= 1),
    children_count INTEGER NOT NULL DEFAULT 0 CHECK (children_count >= 0),
    children_ages JSONB DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Backwards compatibility schema migration (if table already exists)
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS adults_count INTEGER NOT NULL DEFAULT 1;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS children_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS children_ages JSONB DEFAULT '[]'::jsonb;

-- ── 9. GALLERY TABLE ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.gallery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    image_url TEXT NOT NULL,
    category TEXT,
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 10. BLOGS TABLE ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.blogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    title_ar TEXT,
    content TEXT NOT NULL,
    content_ar TEXT,
    image_url TEXT,
    published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 11. TESTIMONIALS TABLE ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.testimonials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    country TEXT,
    trip TEXT,
    review TEXT NOT NULL,
    rating NUMERIC NOT NULL DEFAULT 5.0,
    image_url TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ── 12. PARTNERS TABLE ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    logo_url TEXT NOT NULL,
    website TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ── 13. AIRPORT TRANSFER VEHICLES TABLE ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.transfer_vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_name TEXT NOT NULL,
    vehicle_name_ar TEXT,
    vehicle_type TEXT NOT NULL DEFAULT 'sedan',
    image_url TEXT,
    passenger_capacity INTEGER NOT NULL DEFAULT 3,
    luggage_capacity INTEGER NOT NULL DEFAULT 2,
    supported_transfer_types JSONB NOT NULL DEFAULT '["airport_to_hotel","hotel_to_airport","airport_to_airport","custom"]'::jsonb,
    base_price NUMERIC NOT NULL DEFAULT 45.0,
    currency TEXT NOT NULL DEFAULT 'USD',
    estimated_duration TEXT NOT NULL DEFAULT '45-60 mins',
    features JSONB DEFAULT '["Flight Tracking","Meet & Greet with Name Board","Free 60 min Wait Time","Air Conditioned","Complimentary Bottled Water"]'::jsonb,
    features_ar JSONB,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 14. AIRPORT TRANSFER BOOKINGS TABLE ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.transfer_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES public.transfer_vehicles(id) ON DELETE SET NULL,
    vehicle_type TEXT NOT NULL,
    vehicle_name TEXT,
    transfer_type TEXT NOT NULL CHECK (transfer_type IN ('airport_to_hotel', 'hotel_to_airport', 'airport_to_airport', 'custom')),
    pickup_location TEXT NOT NULL,
    dropoff_location TEXT NOT NULL,
    pickup_date DATE NOT NULL,
    pickup_time TEXT NOT NULL,
    passengers_count INTEGER NOT NULL DEFAULT 1,
    adults_count INTEGER NOT NULL DEFAULT 1 CHECK (adults_count >= 1),
    children_count INTEGER NOT NULL DEFAULT 0 CHECK (children_count >= 0),
    children_ages JSONB DEFAULT '[]'::jsonb,
    luggage_count INTEGER NOT NULL DEFAULT 1 CHECK (luggage_count >= 0),
    total_price NUMERIC NOT NULL DEFAULT 0.0,
    currency TEXT NOT NULL DEFAULT 'USD',
    customer_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    flight_number TEXT,
    special_requests TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── AUTOMATIC UPDATED_AT TRIGGER FUNCTION ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_destinations_updated_at') THEN
        CREATE TRIGGER tr_destinations_updated_at BEFORE UPDATE ON public.destinations
        FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_tours_updated_at') THEN
        CREATE TRIGGER tr_tours_updated_at BEFORE UPDATE ON public.tours
        FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_hotels_updated_at') THEN
        CREATE TRIGGER tr_hotels_updated_at BEFORE UPDATE ON public.hotels
        FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_visa_services_updated_at') THEN
        CREATE TRIGGER tr_visa_services_updated_at BEFORE UPDATE ON public.visa_services
        FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_blogs_updated_at') THEN
        CREATE TRIGGER tr_blogs_updated_at BEFORE UPDATE ON public.blogs
        FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
    END IF;
END $$;

-- ── HELPER FUNCTIONS FOR RLS & ROLE CHECKS ────────────────────────────────────

-- Check if current authenticated user is an admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT (role = 'admin')
        FROM public.profiles
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if current authenticated user is staff or admin
CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT (role IN ('admin', 'staff'))
        FROM public.profiles
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── ROW LEVEL SECURITY (RLS) POLICIES ─────────────────────────────────────────

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tour_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visa_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visa_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partners ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles"
    ON public.profiles FOR SELECT
    USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage profiles" ON public.profiles;
CREATE POLICY "Admins can manage profiles"
    ON public.profiles FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 2. Destinations Policies
DROP POLICY IF EXISTS "Public can view destinations" ON public.destinations;
CREATE POLICY "Public can view destinations"
    ON public.destinations FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Admins can manage destinations" ON public.destinations;
CREATE POLICY "Admins can manage destinations"
    ON public.destinations FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 3. Tours Policies
DROP POLICY IF EXISTS "Public can view active tours" ON public.tours;
CREATE POLICY "Public can view active tours"
    ON public.tours FOR SELECT
    USING (active = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage tours" ON public.tours;
CREATE POLICY "Admins can manage tours"
    ON public.tours FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 4. Tour Images Policies
DROP POLICY IF EXISTS "Public can view tour images" ON public.tour_images;
CREATE POLICY "Public can view tour images"
    ON public.tour_images FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Admins can manage tour images" ON public.tour_images;
CREATE POLICY "Admins can manage tour images"
    ON public.tour_images FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 5. Hotels Policies
DROP POLICY IF EXISTS "Public can view active hotels" ON public.hotels;
CREATE POLICY "Public can view active hotels"
    ON public.hotels FOR SELECT
    USING (active = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage hotels" ON public.hotels;
CREATE POLICY "Admins can manage hotels"
    ON public.hotels FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 6. Visa Services Policies
DROP POLICY IF EXISTS "Public can view active visa services" ON public.visa_services;
CREATE POLICY "Public can view active visa services"
    ON public.visa_services FOR SELECT
    USING (active = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage visa services" ON public.visa_services;
CREATE POLICY "Admins can manage visa services"
    ON public.visa_services FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 7. Visa Requirements Policies
DROP POLICY IF EXISTS "Public can view visa requirements" ON public.visa_requirements;
CREATE POLICY "Public can view visa requirements"
    ON public.visa_requirements FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Admins can manage visa requirements" ON public.visa_requirements;
CREATE POLICY "Admins can manage visa requirements"
    ON public.visa_requirements FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 8. Bookings Policies (Public can insert booking with status 'pending', Staff/Admins can view and update)
DROP POLICY IF EXISTS "Public can create booking" ON public.bookings;
CREATE POLICY "Public can create booking"
    ON public.bookings FOR INSERT
    WITH CHECK (
        status = 'pending' AND
        customer_name IS NOT NULL AND
        email IS NOT NULL AND
        phone IS NOT NULL
    );

DROP POLICY IF EXISTS "Staff and Admins can view bookings" ON public.bookings;
CREATE POLICY "Staff and Admins can view bookings"
    ON public.bookings FOR SELECT
    USING (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Staff and Admins can update bookings" ON public.bookings;
CREATE POLICY "Staff and Admins can update bookings"
    ON public.bookings FOR UPDATE
    USING (public.is_staff_or_admin())
    WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can delete bookings" ON public.bookings;
CREATE POLICY "Admins can delete bookings"
    ON public.bookings FOR DELETE
    USING (public.is_admin());

-- 9. Gallery Policies
DROP POLICY IF EXISTS "Public can view gallery" ON public.gallery;
CREATE POLICY "Public can view gallery"
    ON public.gallery FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Admins can manage gallery" ON public.gallery;
CREATE POLICY "Admins can manage gallery"
    ON public.gallery FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 10. Blogs Policies
DROP POLICY IF EXISTS "Public can view published blogs" ON public.blogs;
CREATE POLICY "Public can view published blogs"
    ON public.blogs FOR SELECT
    USING (published = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage blogs" ON public.blogs;
CREATE POLICY "Admins can manage blogs"
    ON public.blogs FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 11. Testimonials Policies
DROP POLICY IF EXISTS "Public can view active testimonials" ON public.testimonials;
CREATE POLICY "Public can view active testimonials"
    ON public.testimonials FOR SELECT
    USING (active = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage testimonials" ON public.testimonials;
CREATE POLICY "Admins can manage testimonials"
    ON public.testimonials FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 12. Partners Policies
DROP POLICY IF EXISTS "Public can view active partners" ON public.partners;
CREATE POLICY "Public can view active partners"
    ON public.partners FOR SELECT
    USING (active = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage partners" ON public.partners;
CREATE POLICY "Admins can manage partners"
    ON public.partners FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 13. Transfer Vehicles Policies
ALTER TABLE public.transfer_vehicles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view active transfer vehicles" ON public.transfer_vehicles;
CREATE POLICY "Public can view active transfer vehicles"
    ON public.transfer_vehicles FOR SELECT
    USING (active = TRUE OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can manage transfer vehicles" ON public.transfer_vehicles;
CREATE POLICY "Admins can manage transfer vehicles"
    ON public.transfer_vehicles FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 14. Transfer Bookings Policies
ALTER TABLE public.transfer_bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can create transfer booking" ON public.transfer_bookings;
CREATE POLICY "Public can create transfer booking"
    ON public.transfer_bookings FOR INSERT
    WITH CHECK (
        status = 'pending' AND
        customer_name IS NOT NULL AND
        email IS NOT NULL AND
        phone IS NOT NULL
    );

DROP POLICY IF EXISTS "Staff and Admins can view transfer bookings" ON public.transfer_bookings;
CREATE POLICY "Staff and Admins can view transfer bookings"
    ON public.transfer_bookings FOR SELECT
    USING (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Staff and Admins can update transfer bookings" ON public.transfer_bookings;
CREATE POLICY "Staff and Admins can update transfer bookings"
    ON public.transfer_bookings FOR UPDATE
    USING (public.is_staff_or_admin())
    WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Admins can delete transfer bookings" ON public.transfer_bookings;
CREATE POLICY "Admins can delete transfer bookings"
    ON public.transfer_bookings FOR DELETE
    USING (public.is_admin());

-- ── STORAGE BUCKETS SETUP & STORAGE RLS POLICIES ─────────────────────────────

INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('tour-images', 'tour-images', true),
    ('destination-images', 'destination-images', true),
    ('hotel-images', 'hotel-images', true),
    ('gallery-images', 'gallery-images', true),
    ('blog-images', 'blog-images', true),
    ('partner-logos', 'partner-logos', true),
    ('transfer-images', 'transfer-images', true)
ON CONFLICT (id) DO NOTHING;

-- Public can read any objects from these public buckets
DROP POLICY IF EXISTS "Public read storage images" ON storage.objects;
CREATE POLICY "Public read storage images"
    ON storage.objects FOR SELECT
    USING (bucket_id IN ('tour-images', 'destination-images', 'hotel-images', 'gallery-images', 'blog-images', 'partner-logos', 'transfer-images'));

-- Admins can insert/upload objects
DROP POLICY IF EXISTS "Admins insert storage images" ON storage.objects;
CREATE POLICY "Admins insert storage images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id IN ('tour-images', 'destination-images', 'hotel-images', 'gallery-images', 'blog-images', 'partner-logos', 'transfer-images')
        AND (public.is_admin() OR public.is_staff_or_admin())
    );

-- Admins can update objects
DROP POLICY IF EXISTS "Admins update storage images" ON storage.objects;
CREATE POLICY "Admins update storage images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id IN ('tour-images', 'destination-images', 'hotel-images', 'gallery-images', 'blog-images', 'partner-logos')
        AND public.is_admin()
    );

-- Admins can delete objects
DROP POLICY IF EXISTS "Admins delete storage images" ON storage.objects;
CREATE POLICY "Admins delete storage images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id IN ('tour-images', 'destination-images', 'hotel-images', 'gallery-images', 'blog-images', 'partner-logos')
        AND public.is_admin()
    );

-- ── 15. SITE SETTINGS TABLE ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.site_settings (
    id TEXT PRIMARY KEY DEFAULT 'default',
    site_name TEXT NOT NULL DEFAULT 'Travella Tour & Travel',
    site_name_ar TEXT NOT NULL DEFAULT 'ترافيلا للسياحة والسفر',
    support_email TEXT NOT NULL DEFAULT 'info@travella.com',
    phone_number TEXT NOT NULL DEFAULT '+20 100 123 4567',
    cairo_address TEXT NOT NULL DEFAULT 'Zamalek, Cairo, Egypt',
    cairo_address_ar TEXT NOT NULL DEFAULT 'الزمالك، القاهرة، جمهورية مصر العربية',
    facebook_url TEXT NOT NULL DEFAULT 'https://facebook.com/travella',
    instagram_url TEXT NOT NULL DEFAULT 'https://instagram.com/travella',
    whatsapp_number TEXT NOT NULL DEFAULT '+20 100 123 4567',
    youtube_url TEXT NOT NULL DEFAULT 'https://youtube.com/@travella',
    tiktok_url TEXT NOT NULL DEFAULT 'https://tiktok.com/@travella',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed default site_settings row
INSERT INTO public.site_settings (
    id, site_name, site_name_ar, support_email, phone_number,
    cairo_address, cairo_address_ar, facebook_url, instagram_url,
    whatsapp_number, youtube_url, tiktok_url
) VALUES (
    'default',
    'Travella Tour & Travel',
    'ترافيلا للسياحة والسفر',
    'info@travella.com',
    '+20 100 123 4567',
    'Zamalek, Cairo, Egypt',
    'الزمالك، القاهرة، جمهورية مصر العربية',
    'https://facebook.com/travella',
    'https://instagram.com/travella',
    '+20 100 123 4567',
    'https://youtube.com/@travella',
    'https://tiktok.com/@travella'
) ON CONFLICT (id) DO NOTHING;

-- Site Settings Policies
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view site settings" ON public.site_settings;
CREATE POLICY "Public can view site settings"
    ON public.site_settings FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Admins can update site settings" ON public.site_settings;
CREATE POLICY "Admins can update site settings"
    ON public.site_settings FOR ALL
    USING (public.is_admin() OR public.is_staff_or_admin())
    WITH CHECK (public.is_admin() OR public.is_staff_or_admin());

