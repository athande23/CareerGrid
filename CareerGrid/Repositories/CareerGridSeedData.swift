
import Foundation

enum CareerGridSeedData {
    private static func deadline(month: Int, day: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone =
            TimeZone(identifier: "Australia/Sydney") ?? .current

        return calendar.date(
            from: DateComponents(
                year: 2027,
                month: month,
                day: day,
                hour: 23,
                minute: 59
            )
        )
    }

    private static func makeOpportunity(
        id: String,
        companyID: String,
        role: String,
        company: String,
        industry: String,
        deadlineMonth: Int,
        deadlineDay: Int,
        degreeRequirement: String,
        requirements: String,
        url: String,
        description: String
    ) -> JobOpportunityModel {
        JobOpportunityModel(
            id: UUID(uuidString: id)!,
            roleTitle: role,
            company: CompanyModel(
                id: UUID(uuidString: companyID)!,
                name: company
            ),
            industry: industry,
            location: "Sydney, NSW",
            description: description,
            requirements: requirements,
            sourceURL: URL(string: url),
            applicationDeadline: deadline(
                month: deadlineMonth,
                day: deadlineDay
            ),
            degreeRequirement: degreeRequirement
        )
    }

    static let opportunities: [JobOpportunityModel] = [
        makeOpportunity(
            id: "A1000001-0000-4000-8000-000000000001",
            companyID: "B1000001-0000-4000-8000-000000000001",
            role: "Summer Internship - Business Banking",
            company: "CommBank",
            industry: "Finance & Banking",
            deadlineMonth: 1,
            deadlineDay: 15,
            degreeRequirement: "Business & Commerce, Finance, Economics",
            requirements: "Suitable study areas may include finance, economics, commerce and business. Check the official program for eligibility.",
            url: "https://www.commbank.com.au/about-us/careers/graduate-intern-programs.html",
            description: "Gain experience in business banking, financial services and customer relationship management."
        ),

        makeOpportunity(
            id: "A1000002-0000-4000-8000-000000000002",
            companyID: "B1000002-0000-4000-8000-000000000002",
            role: "Investment Banking Summer Analyst",
            company: "JPMorganChase",
            industry: "Finance & Banking",
            deadlineMonth: 2,
            deadlineDay: 15,
            degreeRequirement: "Finance, Economics, Business & Commerce",
            requirements: "Typically suited to students studying finance, economics, business or related fields. Check the role listing for location-specific eligibility.",
            url: "https://careers.jpmorgan.com/",
            description: "Support financial analysis, company research and transactions while learning about investment banking."
        ),

        makeOpportunity(
            id: "A1000003-0000-4000-8000-000000000003",
            companyID: "B1000003-0000-4000-8000-000000000003",
            role: "Graduate Mechanical Engineer",
            company: "Arup",
            industry: "Engineering",
            deadlineMonth: 3,
            deadlineDay: 15,
            degreeRequirement: "Engineering",
            requirements: "Relevant engineering degree. Accepted disciplines and graduate eligibility depend on the advertised role.",
            url: "https://www.arup.com/careers/",
            description: "Contribute to building systems, infrastructure and engineering design projects."
        ),

        makeOpportunity(
            id: "A1000004-0000-4000-8000-000000000004",
            companyID: "B1000004-0000-4000-8000-000000000004",
            role: "Graduate Marketing Coordinator",
            company: "Canva",
            industry: "Marketing & Communications",
            deadlineMonth: 4,
            deadlineDay: 15,
            degreeRequirement: "Marketing & Communications, Business & Commerce, Arts & Humanities",
            requirements: "Relevant studies may include marketing, communications, media or business. Check the specific vacancy for requirements.",
            url: "https://www.canva.com/careers/",
            description: "Support campaign planning, content creation, audience research and marketing initiatives."
        ),

        makeOpportunity(
            id: "A1000005-0000-4000-8000-000000000005",
            companyID: "B1000005-0000-4000-8000-000000000005",
            role: "Graduate Accountant",
            company: "KPMG",
            industry: "Accounting & Professional Services",
            deadlineMonth: 5,
            deadlineDay: 15,
            degreeRequirement: "Accounting, Finance, Business & Commerce",
            requirements: "Relevant accounting, finance or commerce studies may be required depending on the graduate stream.",
            url: "https://kpmg.com/au/en/careers/students.html",
            description: "Develop accounting, financial reporting and advisory skills while working with clients."
        ),

        makeOpportunity(
            id: "A1000006-0000-4000-8000-000000000006",
            companyID: "B1000006-0000-4000-8000-000000000006",
            role: "Graduate Policy Officer",
            company: "ASIC",
            industry: "Government & Regulation",
            deadlineMonth: 6,
            deadlineDay: 15,
            degreeRequirement: "Law & Policy, Economics, Business & Commerce, Arts & Humanities",
            requirements: "Relevant backgrounds may include law, economics, public policy, commerce or related disciplines. Confirm eligibility in the official listing.",
            url: "https://careers.asic.gov.au/",
            description: "Contribute to research, policy development and regulatory initiatives in Australia's financial system."
        ),

        makeOpportunity(
            id: "A1000007-0000-4000-8000-000000000007",
            companyID: "B1000007-0000-4000-8000-000000000007",
            role: "Graduate Consultant",
            company: "Deloitte",
            industry: "Consulting",
            deadlineMonth: 7,
            deadlineDay: 15,
            degreeRequirement: "Any degree",
            requirements: "Degree requirements depend on the consulting stream. Review the official graduate program listing.",
            url: "https://www.deloitte.com/au/en/careers.html",
            description: "Work with organisations on business challenges, strategy, operations and transformation projects."
        ),

        makeOpportunity(
            id: "A1000008-0000-4000-8000-000000000008",
            companyID: "B1000008-0000-4000-8000-000000000008",
            role: "Graduate Solicitor",
            company: "Ashurst",
            industry: "Legal Services",
            deadlineMonth: 8,
            deadlineDay: 15,
            degreeRequirement: "Law & Policy",
            requirements: "Law degree and applicable admission or practical legal training requirements. Check the firm's graduate recruitment information.",
            url: "https://www.ashurst.com/en/careers/",
            description: "Build legal research, drafting and client advisory experience within a commercial law firm."
        ),

        makeOpportunity(
            id: "A1000009-0000-4000-8000-000000000009",
            companyID: "B1000009-0000-4000-8000-000000000009",
            role: "Graduate Environmental Scientist",
            company: "AECOM",
            industry: "Environment & Science",
            deadlineMonth: 9,
            deadlineDay: 15,
            degreeRequirement: "Science, Environmental Studies, Engineering",
            requirements: "Relevant studies may include environmental science, ecology, environmental engineering or related disciplines.",
            url: "https://aecom.com/careers/",
            description: "Support environmental assessments, field investigations and sustainability projects."
        ),

        makeOpportunity(
            id: "A1000010-0000-4000-8000-000000000010",
            companyID: "B1000010-0000-4000-8000-000000000010",
            role: "Human Resources Graduate",
            company: "Westpac",
            industry: "Human Resources",
            deadlineMonth: 10,
            deadlineDay: 15,
            degreeRequirement: "Human Resources, Business & Commerce, Psychology, Arts & Humanities",
            requirements: "Relevant studies may include human resources, business, psychology or related disciplines. Confirm requirements in the official program listing.",
            url: "https://www.westpac.com.au/about-westpac/careers/",
            description: "Support recruitment, employee experience, people strategy and organisational development."
        )
    ]
}
