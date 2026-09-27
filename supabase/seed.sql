-- ==============================================================================
-- TRAVELLA TOUR & TRAVEL — SEED DATA FOR SUPABASE
-- (All UUIDs use valid hex characters 0-9, a-f)
-- ==============================================================================

-- 1. DESTINATIONS SEED DATA
INSERT INTO public.destinations (id, name, name_ar, description, description_ar, country, image_url, featured)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'Istanbul', 'إسطنبول', 'Where East meets West across the Bosphorus strait. Iconic Ottoman mosques, bustling grand bazaars, and scenic cruises.', 'حيث يلتقي الشرق بالغرب عبر مضيق البوسفور. مساجد عثمانية أيقونية، وأسواق تاريخية نابضة بالحياة.', 'Turkey', 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000002', 'Paris', 'باريس', 'The City of Light. Romantic Seine cruises, Louvre masterpieces, and timeless haute cuisine.', 'مدينة النور. رحلات رومانسية في نهر السين، وروائع متحف اللوفر، وأرقى فنون الطهي الفرنسية.', 'France', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000003', 'Dubai', 'دبي', 'Ultra-modern marvels, desert safaris, world-class shopping, and private yacht cruises in the Arabian Gulf.', 'عجائب معمارية فائقة الحداثة، ورحلات سفاري صحراوية، وتسوق عالمي، ويخوت فاخرة في الخليج العربي.', 'United Arab Emirates', 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000004', 'Maldives', 'المالديف', 'Overwater luxury villas, pristine turquoise lagoons, and private coral reef diving experiences.', 'فلل فاخرة فوق الماء، وبحيرات فيروزية نقية، وتجارب غوص فريدة بين الشعاب المرجانية.', 'Maldives', 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000005', 'Sharm El Sheikh', 'شرم الشيخ', 'The Jewel of Sinai. World-renowned diving in Ras Mohammed, luxury all-inclusive resorts, and desert stargazing.', 'لؤلؤة سيناء. غوص عالمي في رأس محمد، ومنتجعات شاملة راقية، وسهرات صحراوية تحت النجوم.', 'Egypt', 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000006', 'Hurghada', 'الغردقة', 'Crystal-clear turquoise waters of Giftun Island, desert quad safaris, and vibrant marine coral life.', 'مياه فيروزية صافية في جزيرة جفتون، ورحلات سفاري بالدراجات الرباعية، وتنوع بحري رائع.', 'Egypt', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000007', 'Siwa Oasis', 'واحة سيوة', 'Mystical eco-lodges, crystal salt lakes, Cleopatra springs, and sunset over the Great Sand Sea dunes.', 'نزل بيئية ساحرة، وبحيرات ملح كريستالية، وعين كليوباترا، وغروب مهيب فوق بحر الرمال الأعظم.', 'Egypt', 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85', true),
    ('00000000-0000-0000-0000-000000000008', 'Aswan & Luxor', 'أسوان والأقصر', 'Pharaonic grandeur along the timeless Nile. Valley of the Kings, Karnak, and Philae Temple.', 'عظمة الفراعنة على ضفاف النيل الخالد. وادي الملوك، ومعابد الكرنك، وفيلة.', 'Egypt', 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1200&q=85', true)
ON CONFLICT (id) DO NOTHING;

-- 2. TOURS SEED DATA (Domestic, International, Hajj, Umrah)
INSERT INTO public.tours (id, title, title_ar, description, description_ar, destination_id, type, duration, price, currency, image_url, featured, active)
VALUES 
    -- Domestic Tours
    ('10000000-0000-0000-0000-000000000001', 'Hurghada Red Sea & Giftun Island Adventure', 'مغامرة الغردقة والبحر الأحمر وجزيرة جفتون', 'Experience 5-star beachfront luxury, private boat cruise to Giftun Island, snorkeling in coral reefs, and desert dinner.', 'استمتع بإقامة فاخرة 5 نجوم على الشاطئ، ورحلة يخت خاصة إلى جزيرة جفتون، وغوص وسط الشعاب المرجانية.', '00000000-0000-0000-0000-000000000006', 'domestic', '4 Days / 3 Nights', 320, 'USD', 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-000000000002', 'Sharm El Sheikh Ras Mohammed & Sinai Safari', 'شرم الشيخ رأس محمد وسفاري سيناء', 'Exclusive resort stay at Naama Bay, world-famous diving at Ras Mohammed National Park, and Mount Sinai sunrise hike.', 'إقامة حصرية في خليج نعمة، وغوص في محمية رأس محمد العالمية، وصعود جبل موسى عند شروق الشمس.', '00000000-0000-0000-0000-000000000005', 'domestic', '5 Days / 4 Nights', 360, 'USD', 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-000000000003', 'Siwa Eco-Lodge & Salt Lakes Escape', 'رحلة واحة سيوة وبحيرات الملح الساحرة', 'Unplug in the magical Siwa Oasis. Swim in hypersaline turquoise lakes, stay at an eco-lodge, explore Shali Fortress.', 'انعزل في واحة سيوة الساحرة. اسبح في بحيرات الملح الفيروزية، وأقم في نزل بيئي فاخر، واستكشف قلعة شالي.', '00000000-0000-0000-0000-000000000007', 'domestic', '4 Days / 3 Nights', 430, 'USD', 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1000&q=80', false, true),
    ('10000000-0000-0000-0000-000000000004', 'Royal Nile Cruise: Aswan to Luxor Heritage', 'رحلة نايل كروز الملكية: تراث أسوان والأقصر', 'Sail the timeless Nile aboard a 5-star luxury cruise ship. Private guided tours of Valley of the Kings and Karnak.', 'أبحر في نهر النيل الخالد على متن باخرة سياحية 5 نجوم فاخرة، مع جولات خاصة لوادي الملوك والكرنك.', '00000000-0000-0000-0000-000000000008', 'domestic', '5 Days / 4 Nights', 520, 'USD', 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1000&q=80', true, true),

    -- International Tours
    ('10000000-0000-0000-0000-000000000005', 'Grand Istanbul & Ottoman Palaces', 'إسطنبول الكبرى والقصور العثمانية', 'Immerse in the magic of Istanbul with private Bosphorus yacht sunset cruise, Hagia Sophia entry, and Taksim culinary walk.', 'عش سحر إسطنبول مع رحلة يخت خاصة في البوسفور عند الغروب، وزيارة آيا صوفيا، وجولة طعام في تقسيم.', '00000000-0000-0000-0000-000000000001', 'international', '6 Days / 5 Nights', 640, 'USD', 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-000000000006', 'Romantic Paris & Versailles Splendor', 'باريس الرومانسية وروعة فرساي', 'Experience Paris in supreme comfort. Seine dinner cruise, Palace of Versailles day tour, and Louvre guided visit.', 'اختبر باريس بأقصى درجات الراحة والرفاهية. عشاء على متن باخرة بالسين، وجولة في قصر فرساي ومتحف اللوفر.', '00000000-0000-0000-0000-000000000002', 'international', '7 Days / 6 Nights', 1280, 'USD', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-000000000007', 'Dubai Ultimate Luxury & Desert Dunes', 'دبي قمة الفخامة والكثبان الصحراوية', 'Burj Khalifa sky lounge, VIP 4x4 desert safari with private barbecue, and Marina luxury yacht cruise.', 'برج خليفة، وسفاري صحراوي بسيارات دفع رباعي مع عشاء باربكيو فاخر، ورحلة يخت في مارينا دبي.', '00000000-0000-0000-0000-000000000003', 'international', '5 Days / 4 Nights', 890, 'USD', 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-000000000008', 'Maldives Overwater Luxury Escape', 'ملاذ المالديف الفاخر فوق الماء', 'Private overwater bungalow with direct ocean access, dolphin sunset cruise, and premium all-inclusive dining.', 'فيلا خاصة فوق المياه مع وصول مباشر للمحيط، ورحلة لمشاهدة الدلافين، ووجبات فاخرة متكاملة.', '00000000-0000-0000-0000-000000000004', 'international', '6 Days / 5 Nights', 1850, 'USD', 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1000&q=80', true, true),

    -- Hajj & Umrah Packages
    ('10000000-0000-0000-0000-000000000009', 'VIP Diamond Umrah Package', 'باقة العمرة الماسية VIP', '5-star front-row Haram hotels in Makkah (Clock Tower) & Madinah (Oberoi), private luxury transfers, guided ziyarat.', 'فنادق 5 نجوم مطلة مباشرة على الحرم في مكة والمدينة، تنقلات خاصة بسيارات فاخرة، ومرشد ديني متخصص.', NULL, 'umrah', '10 Days / 9 Nights', 1650, 'USD', 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-00000000000a', 'Deluxe Ramadan Umrah Experience', 'تجربة عمرة رمضان الفاخرة', 'Spiritual Ramadan journey with 5-star hotel accommodations walking distance to Haram, iftar & suhoor buffets.', 'رحلة إيمانية في شهر رمضان المبارك مع إقامة راقية بالقرب من الحرم المكي الشريف وبوفيهات إفطار وسحور.', NULL, 'umrah', '14 Days / 13 Nights', 2400, 'USD', 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?auto=format&fit=crop&w=1000&q=80', true, true),
    ('10000000-0000-0000-0000-00000000000b', 'Royal Platinum Hajj Package', 'باقة الحج الملكية البلاتينية', 'Complete 5-star VIP Hajj pilgrimage with air-conditioned Mina & Arafat VIP camps, private transfers, and scholar guides.', 'رحلة حج متكاملة VIP بأرقى معايير الراحة، خيام مكيفة في منى وعرفة، تنقلات خاصة وإشراف ديني ونخبة من العلماء.', NULL, 'hajj', '18 Days / 17 Nights', 5900, 'USD', 'https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?auto=format&fit=crop&w=1000&q=80', true, true)
ON CONFLICT (id) DO NOTHING;

-- 3. HOTELS SEED DATA
INSERT INTO public.hotels (id, name, name_ar, description, location, rating, price, currency, image_url, featured, active)
VALUES 
    ('20000000-0000-0000-0000-000000000001', 'Rixos Premium Seagate', 'ريكسوس بريميوم سيجيت', 'Ultra all-inclusive 5-star beachfront resort in Nabq Bay with 8 swimming pools and a luxury spa.', 'Nabq Bay, Sharm El Sheikh, Egypt', 4.95, 240, 'USD', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80', true, true),
    ('20000000-0000-0000-0000-000000000002', 'Atlantis The Royal', 'أتلانتس ذا رويال', 'Iconic ultra-luxury resort on Palm Jumeirah with Cloud 22 sky pool and celebrity restaurants.', 'Palm Jumeirah, Dubai, UAE', 4.98, 680, 'USD', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1000&q=80', true, true),
    ('20000000-0000-0000-0000-000000000003', 'Four Seasons Hotel Bosphorus', 'فور سيزونز البوسفور', '19th-century Ottoman palace on the Bosphorus with heated outdoor pool and Michelin-guide dining.', 'Besiktas, Istanbul, Turkey', 4.94, 490, 'USD', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1000&q=80', true, true),
    ('20000000-0000-0000-0000-000000000004', 'Waldorf Astoria Ithaafushi', 'والدورف أستوريا إيثافوشي', 'Pinnacle of luxury overwater villas with private infinity pools and dedicated butler service.', 'South Male Atoll, Maldives', 5.00, 1250, 'USD', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1000&q=80', true, true)
ON CONFLICT (id) DO NOTHING;

-- 4. VISA SERVICES SEED DATA
INSERT INTO public.visa_services (id, country, country_ar, visa_type, description, description_ar, processing_time, price, active)
VALUES 
    ('30000000-0000-0000-0000-000000000001', 'Schengen Area (Europe)', 'منطقة الشنغن (أوروبا)', 'Tourist / Business Visa', 'Complete application assistance, appointment booking, file audit, and flight/hotel reservation voucher support.', 'مساعدة كاملة في تقديم الطلب، وحجز المواعيد، ومراجعة المستندات، وتوفير حجوزات الطيران والفنادق المعتمدة.', '10 - 15 Days', 180, true),
    ('30000000-0000-0000-0000-000000000002', 'United Kingdom', 'المملكة المتحدة', 'Standard Visitor Visa', 'Online application completion, biometric appointment scheduling, and document translation checks.', 'تعبئة استمارة التقديم الإلكترونية، وحجز موعد البصمة، وتدقيق الوثائق والمستندات المترجمة.', '15 - 20 Days', 220, true),
    ('30000000-0000-0000-0000-000000000003', 'United States (USA)', 'الولايات المتحدة الأمريكية', 'B1/B2 Tourist & Business', 'DS-160 application form filing, fee payment, earlier appointment tracking, and interview preparation coaching.', 'تعبئة نموذج DS-160، ودفع الرسوم، وتتبع المواعيد المبكرة، والتدريب على مقابلة السفارة.', '20 - 30 Days', 250, true),
    ('30000000-0000-0000-0000-000000000004', 'United Arab Emirates (Dubai)', 'الإمارات العربية المتحدة (دبي)', '30/60 Days Tourist eVisa', 'Fast-track electronic visa issuance within 24 to 48 hours directly into your email with health insurance.', 'إصدار التأشيرة الإلكترونية السريعة خلال 24 إلى 48 ساعة مباشرة على بريدك الإلكتروني مع التأمين الصحي.', '24 - 48 Hours', 110, true)
ON CONFLICT (id) DO NOTHING;

-- 5. VISA REQUIREMENTS SEED DATA
INSERT INTO public.visa_requirements (visa_service_id, requirement, requirement_ar)
VALUES 
    ('30000000-0000-0000-0000-000000000001', 'Original Passport valid for at least 6 months with 2 blank pages', 'جواز سفر أصلي ساري المفعول لمدة لا تقل عن 6 أشهر مع صفحتين فارغتين'),
    ('30000000-0000-0000-0000-000000000001', 'Bank statement for the last 6 months stamped by the bank', 'كشف حساب بنكي لآخر 6 أشهر مختوم من البنك'),
    ('30000000-0000-0000-0000-000000000001', 'HR Letter from employer or Commercial Register & Tax Card for business owners', 'خطاب عمل (HR Letter) أو سجل تجاري وبطاقة ضريبية لأصحاب الأعمال'),
    ('30000000-0000-0000-0000-000000000002', 'Valid Passport & all previous expired passports', 'جواز السفر الحالي وجميع الجوازات السابقة المنتهية'),
    ('30000000-0000-0000-0000-000000000002', 'Proof of funds and 6 months bank statements', 'إثبات مصادر الدخل وكشف حساب بنكي لآخر 6 أشهر'),
    ('30000000-0000-0000-0000-000000000003', 'Completed DS-160 confirmation barcode', 'باركود تأكيد استمارة DS-160'),
    ('30000000-0000-0000-0000-000000000003', '2 recent biometric photos with white background (5x5 cm)', 'صورتان شخصيتان حديثتان بخلفية بيضاء (5×5 سم)'),
    ('30000000-0000-0000-0000-000000000004', 'Clear colored passport copy (bio page)', 'صورة ملونة واضحة للصفحة الأولى لجواز السفر'),
    ('30000000-0000-0000-0000-000000000004', 'Passport size photo with white background', 'صورة شخصية بخلفية بيضاء')
ON CONFLICT DO NOTHING;

-- 6. GALLERY SEED DATA
INSERT INTO public.gallery (id, title, image_url, category, featured)
VALUES 
    ('40000000-0000-0000-0000-000000000001', 'Santorini Sunset Cliffside', 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=800&q=80', 'Beach', true),
    ('40000000-0000-0000-0000-000000000002', 'Swiss Alps Alpine Panorama', 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=800&q=80', 'Adventure', true),
    ('40000000-0000-0000-0000-000000000003', 'Phuket Andaman Sea Longtail', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80', 'Beach', true),
    ('40000000-0000-0000-0000-000000000004', 'Kyoto Arashiyama Bamboo Grove', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80', 'Culture', true),
    ('40000000-0000-0000-0000-000000000005', 'Amalfi Coast Positano Village', 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=800&q=80', 'Luxury', true),
    ('40000000-0000-0000-0000-000000000006', 'Dubai Desert Dune Safari', 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80', 'Desert', true)
ON CONFLICT (id) DO NOTHING;

-- 7. BLOGS SEED DATA
INSERT INTO public.blogs (id, title, title_ar, content, content_ar, image_url, published)
VALUES 
    (
        '50000000-0000-0000-0000-000000000001',
        'Top 10 Hidden Gems in Egypt You Must Visit in 2026', 
        'أفضل 10 أماكن ساحرة ومخفية في مصر يجب زيارتها في عام 2026',
        'From the crystalline salt lakes of Siwa Oasis to the serene turquoise bays of Marsa Alam and the bohemian charm of Dahab, discover Egypt beyond the iconic Pyramids.',
        'من بحيرات الملح الكريستالية في واحة سيوة إلى الشواطئ الفيروزية البكر في مرسى علم وسحر دهب الهادئ، اكتشف جمال مصر الحقيقي وتجاربها الساحرة.',
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=80',
        true
    ),
    (
        '50000000-0000-0000-0000-000000000002',
        'The Ultimate Luxury Travel Packing Guide for Europe',
        'الدليل الشامل لأناقة السفر الفاخر عبر العواصم الأوروبية',
        'Expert tips on capsule wardrobes, premium travel accessories, electronic adapters, and navigating European climates with effortless style and comfort.',
        'نصائح الخبراء حول تنظيم حقيبة السفر الأنيقة، والإكسسوارات الفاخرة، ومحولات الكهرباء، واستكشاف العواصم الأوروبية بأعلى درجات الراحة والأناقة.',
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=80',
        true
    ),
    (
        '50000000-0000-0000-0000-000000000003',
        'Essential Spiritual & Practical Guide for First-Time Umrah Pilgrims',
        'الدليل الروحي والعملي المتكامل للمعتمرين لأول مرة',
        'A comprehensive step-by-step walkthrough covering Ihram requirements, Tawaf and Sa’i etiquette, recommended prayers, and packing essentials for Makkah and Madinah.',
        'دليل شامل خطوة بخطوة يشمل أحكام الإحرام، وسنن الطواف والسعي، والأدعية المستحبة، وأهم المستلزمات لرحلة روحانية ميسرة في مكة المكرمة والمدينة المنورة.',
        'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1200&q=80',
        true
    )
ON CONFLICT (id) DO NOTHING;

-- 8. TESTIMONIALS SEED DATA
INSERT INTO public.testimonials (id, name, country, trip, review, rating, image_url, active)
VALUES 
    ('60000000-0000-0000-0000-000000000001', 'Ahmed & Sarah Mansour', 'Egypt', 'Maldives VIP Overwater Escape', 'Travella orchestrated our dream honeymoon to perfection. Every detail from the seaplane transfer to the private sandbank dinner was flawless.', 5.0, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', true),
    ('60000000-0000-0000-0000-000000000002', 'Dr. Khaled El-Sayed', 'Saudi Arabia', 'Royal Nile Cruise Heritage', 'The Nile cruise was an unforgettable voyage through history. The private Egyptologist was phenomenal and the 5-star service was world-class.', 5.0, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', true),
    ('60000000-0000-0000-0000-000000000003', 'Fatima Al-Zahraa', 'UAE', 'VIP Diamond Umrah Package', 'Flawless arrangements for our family Umrah. The hotel was steps away from the Haram, making it effortless for my elderly parents. May Allah reward you.', 5.0, 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80', true)
ON CONFLICT (id) DO NOTHING;

-- 9. PARTNERS SEED DATA
INSERT INTO public.partners (id, name, logo_url, website, active)
VALUES 
    ('70000000-0000-0000-0000-000000000001', 'Emirates Airlines', 'https://upload.wikimedia.org/wikipedia/commons/d/d0/Emirates_logo.svg', 'https://www.emirates.com', true),
    ('70000000-0000-0000-0000-000000000002', 'EgyptAir', 'https://upload.wikimedia.org/wikipedia/commons/a/a2/EgyptAir_logo.svg', 'https://www.egyptair.com', true),
    ('70000000-0000-0000-0000-000000000003', 'Turkish Airlines', 'https://upload.wikimedia.org/wikipedia/commons/0/00/Turkish_Airlines_logo_2019.svg', 'https://www.turkishairlines.com', true),
    ('70000000-0000-0000-0000-000000000004', 'Four Seasons Hotels', 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Four_Seasons_Hotels_and_Resorts_logo.svg', 'https://www.fourseasons.com', true),
    ('70000000-0000-0000-0000-000000000005', 'Marriott International', 'https://upload.wikimedia.org/wikipedia/commons/2/20/Marriott_International_Logo.svg', 'https://www.marriott.com', true)
ON CONFLICT (id) DO NOTHING;
