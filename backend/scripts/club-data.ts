/**
 * Structured transcription of club_info.pdf (as supplied 2026-09-02).
 * This is the canonical source `scripts/import-clubs.ts` reads from.
 *
 * If club_info.md/pdf is updated, re-transcribe it into this file (or
 * swap in a PDF/Markdown parser) and re-run the import script — it's
 * idempotent, matched on `email`.
 *
 * Fields NOT present in the source PDF (club email, coordinator email,
 * department, category) are inferred/placeholders — see README-import.md
 * for exactly which and why. Leadership names are transcribed as given;
 * `about` text is transcribed verbatim, including one apparent
 * copy-paste error in the source (Danceaddix) — not corrected here.
 */

export interface ClubSeed {
  /** Canonical display name. */
  name: string;
  /** Lowercase keys used to match logo/banner filenames (e.g. "<key>_logo.*"). */
  assetKeys: string[];
  about: string;
  category: string;
  department: string | null;
  leadership: { role: string; name: string }[];
}

export const CLUBS: ClubSeed[] = [
  {
    name: "Pentagram",
    assetKeys: ["pentagram"],
    about:
      "The Pentagram Club aims to foster and enhance students' mathematical understanding by organizing engaging games and events that challenge and develop their aptitude, logical reasoning, and critical thinking skills.",
    category: "Technical",
    department: null,
    leadership: [
      { role: "President", name: "Aayush Ranjan" },
      { role: "Vice President", name: "Arunank Shankar" },
      { role: "Secretary", name: "Prateeksha Bhat" },
      { role: "Financial Head", name: "Kumar Saurav" },
      { role: "Design and Social Media Head", name: "Shivam Savant" },
      { role: "Student Council Head", name: "B Thanmai" },
      { role: "Student Coordinators", name: "Baibhav Giri and Keerthana H Bhat" },
      { role: "Event Organizing Head", name: "Pranamya and Ranganayaki" },
    ],
  },
  {
    name: "Protocol",
    assetKeys: ["protocol"],
    about:
      "Protocol is the Computer Science and Engineering Department Club of BMSCE, focused on promoting technology, innovation, and collaboration among students. We conduct hackathons, workshops, technical events, competitions, and projects, while providing students with opportunities to learn new technologies, build practical skills, and work together beyond the classroom.",
    category: "Technical",
    department: "Computer Science",
    leadership: [
      { role: "President", name: "Deeptanshu Sarangi" },
      { role: "Vice President", name: "Varsha Kodi" },
      { role: "Secretary", name: "Abhigyan Shekhar" },
      { role: "Technical Head", name: "Adarsh KP" },
      { role: "Design Head", name: "Shaistha Haja" },
    ],
  },
  {
    name: "OSCode",
    assetKeys: ["oscode"],
    about:
      "OSCode BMSCE is a student-led tech community at BMS College of Engineering. We help students learn beyond the classroom and connect with real-world technology. Explore AI, Machine Learning, Web Development, Open Source, and emerging technologies while working with other students, sharing ideas, and building projects together. Learn. Build. Collaborate. Grow.",
    category: "Technical",
    department: null,
    leadership: [
      { role: "Team Lead", name: "Anamika Dubey" },
      { role: "Team Co-Lead", name: "Hitesh S" },
      { role: "Events Head", name: "Divyansh Duggad" },
      { role: "Design Head", name: "Royden Miranda" },
      { role: "PR Head", name: "Priyanshi Singh" },
      { role: "Partnerships Head", name: "Theeksha R" },
      { role: "Tech Head", name: "Shreyash Shaurya" },
      { role: "Tech Co-Head", name: "Yash Shrivastava" },
      { role: "Community Manager", name: "Bhumika S Patil" },
      { role: "Secretary", name: "Athena Ajeesh" },
    ],
  },
  {
    name: "IEEE",
    assetKeys: ["ieee"],
    about:
      "IEEE BMSCE is a student-led technical community at BMS College of Engineering. It gives students opportunities to learn new technologies, work on projects, attend workshops and events, and develop technical and leadership skills through collaboration.",
    category: "Technical",
    department: null,
    leadership: [
      { role: "Chairperson", name: "Nakul" },
      { role: "Vice Chairperson", name: "Udayram" },
    ],
  },
  {
    name: "Rotaract",
    assetKeys: ["rotaract"],
    about:
      "Rotaract BMSCE is a student-led community focused on service, leadership, and personal growth. It gives students opportunities to take part in social initiatives, organize events, build connections, and develop teamwork and leadership skills while making a positive impact.",
    category: "Social Service",
    department: null,
    leadership: [
      { role: "President", name: "Samyak R" },
      { role: "Vice President", name: "Sushanth Gowda" },
      { role: "Secretary", name: "Sharanabasappa Biradar" },
      { role: "Joint Secretary", name: "Himashree B" },
      { role: "Treasurer", name: "Vishavnavi" },
    ],
  },
  {
    name: "Danceaddix",
    // Source file is spelled "danzaddix_logo.jpeg" — different spelling
    // from the club name in club_info.pdf ("DANCEADDIX"). Matched as an
    // alias; flagged in the import report rather than silently assumed.
    assetKeys: ["danceaddix", "danzaddix"],
    about:
      "Rotaract BMSCE is a student-led community focused on service, leadership, and personal growth. It gives students opportunities to take part in social initiatives, organize events, build connections, and develop teamwork and leadership skills while making a positive impact.",
    category: "Cultural",
    department: null,
    leadership: [],
  },
  {
    name: "Mountaineering",
    assetKeys: ["mountaineering"],
    about:
      "Rotaract Mountaineering Club BMSCE is a student community for those interested in adventure, trekking, and outdoor activities. It encourages students to explore the outdoors, build teamwork and confidence, and take part in exciting adventures.",
    category: "Sports",
    department: null,
    leadership: [
      { role: "Coordinator", name: "Shubhanshu Raj" },
      { role: "Coordinator", name: "Neeraj TN" },
      { role: "Treasurer", name: "Abhay Achintya" },
    ],
  },
  {
    name: "Panache",
    assetKeys: ["panache"],
    about:
      "Panache is the fashion team of BMSCE, bringing together students passionate about fashion, styling, and modelling. The team gives students a platform to express their creativity, build confidence, and represent the college at fashion shows and cultural events.",
    category: "Arts & Design",
    department: null,
    leadership: [],
  },
];
