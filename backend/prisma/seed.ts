import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import { randomUUID } from "crypto";

const prisma = new PrismaClient();

// Photos from randomuser.me — gender-correct, ethnicity-matched to location.
// URLs are stable (same number always returns the same photo).
// Sizes: original = /portraits/, medium = /portraits/med/, thumb = /portraits/thumb/
const PHOTO_MAP: Record<string, { original: string; medium: string; thumb: string }> = {
  "muhammad.usman96":  { original: "https://randomuser.me/api/portraits/men/65.jpg",    medium: "https://randomuser.me/api/portraits/med/men/65.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/65.jpg" },
  "ali.raza96":        { original: "https://randomuser.me/api/portraits/men/75.jpg",    medium: "https://randomuser.me/api/portraits/med/men/75.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/75.jpg" },
  "hamza.tariq94":     { original: "https://randomuser.me/api/portraits/men/10.jpg",    medium: "https://randomuser.me/api/portraits/med/men/10.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/10.jpg" },
  "bilal.ahmed06":     { original: "https://randomuser.me/api/portraits/men/48.jpg",    medium: "https://randomuser.me/api/portraits/med/men/48.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/48.jpg" },
  "zain.malik98":      { original: "https://randomuser.me/api/portraits/men/11.jpg",    medium: "https://randomuser.me/api/portraits/med/men/11.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/11.jpg" },
  "ayesha.khan97":     { original: "https://randomuser.me/api/portraits/women/32.jpg",  medium: "https://randomuser.me/api/portraits/med/women/32.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/32.jpg" },
  "fatima.sheikh01":   { original: "https://randomuser.me/api/portraits/women/78.jpg",  medium: "https://randomuser.me/api/portraits/med/women/78.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/78.jpg" },
  "zainab.siddiqui07": { original: "https://randomuser.me/api/portraits/women/74.jpg",  medium: "https://randomuser.me/api/portraits/med/women/74.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/74.jpg" },
  "hira.mahmood96":    { original: "https://randomuser.me/api/portraits/women/87.jpg",  medium: "https://randomuser.me/api/portraits/med/women/87.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/87.jpg" },
  "sana.chaudhry07":   { original: "https://randomuser.me/api/portraits/women/5.jpg",   medium: "https://randomuser.me/api/portraits/med/women/5.jpg",   thumb: "https://randomuser.me/api/portraits/thumb/women/5.jpg" },
  "liam_carter20":     { original: "https://randomuser.me/api/portraits/men/66.jpg",    medium: "https://randomuser.me/api/portraits/med/men/66.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/66.jpg" },
  "noah_bennett56":    { original: "https://randomuser.me/api/portraits/men/28.jpg",    medium: "https://randomuser.me/api/portraits/med/men/28.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/28.jpg" },
  "oliver_turner97":   { original: "https://randomuser.me/api/portraits/men/58.jpg",    medium: "https://randomuser.me/api/portraits/med/men/58.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/58.jpg" },
  "ethan_reid41":      { original: "https://randomuser.me/api/portraits/men/82.jpg",    medium: "https://randomuser.me/api/portraits/med/men/82.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/82.jpg" },
  "jack_mitchell98":   { original: "https://randomuser.me/api/portraits/men/60.jpg",    medium: "https://randomuser.me/api/portraits/med/men/60.jpg",    thumb: "https://randomuser.me/api/portraits/thumb/men/60.jpg" },
  "emma_brooks39":     { original: "https://randomuser.me/api/portraits/women/75.jpg",  medium: "https://randomuser.me/api/portraits/med/women/75.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/75.jpg" },
  "sophia_hayes82":    { original: "https://randomuser.me/api/portraits/women/65.jpg",  medium: "https://randomuser.me/api/portraits/med/women/65.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/65.jpg" },
  "amelia_clarke92":   { original: "https://randomuser.me/api/portraits/women/23.jpg",  medium: "https://randomuser.me/api/portraits/med/women/23.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/23.jpg" },
  "chloe_tremblay78":  { original: "https://randomuser.me/api/portraits/women/36.jpg",  medium: "https://randomuser.me/api/portraits/med/women/36.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/36.jpg" },
  "charlotte_kelly27": { original: "https://randomuser.me/api/portraits/women/32.jpg",  medium: "https://randomuser.me/api/portraits/med/women/32.jpg",  thumb: "https://randomuser.me/api/portraits/thumb/women/32.jpg" },
};

function normalizePhone(phone: string): string {
  return phone.replace(/-/g, "");
}

function dobToUnix(dateStr: string): number {
  return Math.floor(new Date(dateStr).getTime() / 1000);
}

const USERS = [
  {
    name: "Muhammad Usman", username: "muhammad.usman96", gender: "Male" as const,
    phone: "+92-301-3341057", dateOfBirth: "1996-07-01", age: 30,
    latitude: "31.509631", longitude: "74.438366", city: "Lahore", state: "Punjab",
  },
  {
    name: "Ali Raza", username: "ali.raza96", gender: "Male" as const,
    phone: "+92-300-8078673", dateOfBirth: "1996-04-19", age: 30,
    latitude: "31.799078", longitude: "74.095711", city: "Lahore", state: "Punjab",
  },
  {
    name: "Hamza Tariq", username: "hamza.tariq94", gender: "Male" as const,
    phone: "+92-321-1445199", dateOfBirth: "1994-09-18", age: 32,
    latitude: "31.535094", longitude: "74.445038", city: "Lahore", state: "Punjab",
  },
  {
    name: "Bilal Ahmed", username: "bilal.ahmed06", gender: "Male" as const,
    phone: "+92-321-8038374", dateOfBirth: "2006-08-03", age: 20,
    latitude: "24.742985", longitude: "67.363733", city: "Karachi", state: "Sindh",
  },
  {
    name: "Zain Malik", username: "zain.malik98", gender: "Male" as const,
    phone: "+92-345-1109031", dateOfBirth: "1998-12-11", age: 27,
    latitude: "24.821196", longitude: "67.169667", city: "Karachi", state: "Sindh",
  },
  {
    name: "Ayesha Khan", username: "ayesha.khan97", gender: "Female" as const,
    phone: "+92-301-4612365", dateOfBirth: "1997-07-31", age: 29,
    latitude: "31.406329", longitude: "74.174801", city: "Lahore", state: "Punjab",
  },
  {
    name: "Fatima Sheikh", username: "fatima.sheikh01", gender: "Female" as const,
    phone: "+92-302-6770619", dateOfBirth: "2001-07-20", age: 25,
    latitude: "31.469054", longitude: "74.695194", city: "Lahore", state: "Punjab",
  },
  {
    name: "Zainab Siddiqui", username: "zainab.siddiqui07", gender: "Female" as const,
    phone: "+92-312-9996414", dateOfBirth: "2007-07-17", age: 19,
    latitude: "25.085045", longitude: "67.137596", city: "Karachi", state: "Sindh",
  },
  {
    name: "Hira Mahmood", username: "hira.mahmood96", gender: "Female" as const,
    phone: "+92-321-5918715", dateOfBirth: "1996-10-19", age: 30,
    latitude: "24.647320", longitude: "67.354588", city: "Karachi", state: "Sindh",
  },
  {
    name: "Sana Chaudhry", username: "sana.chaudhry07", gender: "Female" as const,
    phone: "+92-301-2166941", dateOfBirth: "2007-11-15", age: 19,
    latitude: "24.685592", longitude: "67.369354", city: "Karachi", state: "Sindh",
  },
  {
    name: "Liam Carter", username: "liam_carter20", gender: "Male" as const,
    phone: "+1-212-438-2654", dateOfBirth: "1995-01-11", age: 31,
    latitude: "40.738333", longitude: "-74.236775", city: "New York", state: "New York",
  },
  {
    name: "Noah Bennett", username: "noah_bennett56", gender: "Male" as const,
    phone: "+1-212-366-7065", dateOfBirth: "2002-07-11", age: 24,
    latitude: "40.660274", longitude: "-74.286293", city: "Newark", state: "New Jersey",
  },
  {
    name: "Oliver Turner", username: "oliver_turner97", gender: "Male" as const,
    phone: "+44-7763-174870", dateOfBirth: "2001-12-20", age: 24,
    latitude: "51.496806", longitude: "0.031160", city: "London", state: "England",
  },
  {
    name: "Ethan Reid", username: "ethan_reid41", gender: "Male" as const,
    phone: "+1-416-367-8573", dateOfBirth: "2007-08-31", age: 19,
    latitude: "43.483941", longitude: "-79.434165", city: "Toronto", state: "Ontario",
  },
  {
    name: "Jack Mitchell", username: "jack_mitchell98", gender: "Male" as const,
    phone: "+61-481-324-801", dateOfBirth: "2002-07-06", age: 24,
    latitude: "-33.768036", longitude: "151.147841", city: "Sydney", state: "New South Wales",
  },
  {
    name: "Emma Brooks", username: "emma_brooks39", gender: "Female" as const,
    phone: "+1-212-232-6168", dateOfBirth: "2001-04-10", age: 25,
    latitude: "40.710659", longitude: "-74.203862", city: "Brooklyn", state: "New York",
  },
  {
    name: "Sophia Hayes", username: "sophia_hayes82", gender: "Female" as const,
    phone: "+1-212-935-6155", dateOfBirth: "2002-12-31", age: 23,
    latitude: "40.745101", longitude: "-73.899125", city: "Jersey City", state: "New Jersey",
  },
  {
    name: "Amelia Clarke", username: "amelia_clarke92", gender: "Female" as const,
    phone: "+44-7569-249811", dateOfBirth: "1998-10-08", age: 28,
    latitude: "51.236707", longitude: "0.073727", city: "Croydon", state: "England",
  },
  {
    name: "Chloe Tremblay", username: "chloe_tremblay78", gender: "Female" as const,
    phone: "+1-416-469-8019", dateOfBirth: "1999-12-10", age: 26,
    latitude: "43.586443", longitude: "-79.756197", city: "Mississauga", state: "Ontario",
  },
  {
    name: "Charlotte Kelly", username: "charlotte_kelly27", gender: "Female" as const,
    phone: "+61-475-605-193", dateOfBirth: "2007-02-02", age: 19,
    latitude: "-33.788680", longitude: "151.163397", city: "Parramatta", state: "New South Wales",
  },
];

async function main() {
  console.log("Seeding dummy users...\n");

  for (const u of USERS) {
    const phone = normalizePhone(u.phone);

    const existing = await prisma.user.findUnique({ where: { phone_number: phone } });
    if (existing) {
      console.log(`⏭  Skipped (already exists): ${u.name} (${phone})`);
      continue;
    }

    const [firstName, ...rest] = u.name.split(" ");
    const lastName = rest.join(" ");

    await prisma.user.create({
      data: {
        phone_number: phone,
        authentication_token: randomUUID(),
        first_name: firstName,
        last_name: lastName,
        user_name: u.username.toLowerCase(),
        gender: u.gender.toLowerCase(),
        dob: dobToUnix(u.dateOfBirth),
        age: u.age,
        latitude: u.latitude,
        longitude: u.longitude,
        city: u.city,
        state: u.state,
        setting: { create: {} },
        photos: {
          create: {
            ...PHOTO_MAP[u.username.toLowerCase()],
            is_primary: true,
            order: 0,
          },
        },
      },
    });

    console.log(`✅  Created: ${u.name} (${phone})`);
  }

  console.log("\nDone.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
