
import Foundation

struct SeedInterviewQuestion {
    let question: String
    let exampleAnswer: String
    let category: InterviewQuestionCategory
}

enum CareerGridInterviewQuestionSeedData {

    static func questions(for companyName: String) -> [SeedInterviewQuestion] {
        switch companyName.lowercased() {

        case "commbank":
            return [
                SeedInterviewQuestion(
                    question: "How would you identify the right business banking solution for a small business customer?",
                    exampleAnswer: "I would first understand the customer's business model, cash flow, growth plans and financial challenges. For example, when I worked on [project or experience], I identified [specific need] and recommended [solution]. I would apply the same customer-focused approach when considering suitable banking products and services.",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "Why are you interested in business banking at CommBank?",
                    exampleAnswer: "I am interested in how business banking helps Australian businesses manage cash flow, fund growth and make financial decisions. CommBank appeals to me because of [specific company initiative, service or value]. My experience in [relevant study or experience] has developed my skills in [relevant skill], which I would like to apply to supporting business customers.",
                    category: .company
                ),
                SeedInterviewQuestion(
                    question: "Tell me about a time you built a relationship with someone who had different needs or priorities.",
                    exampleAnswer: "During [situation], I worked with [person or group] who needed [specific need]. I listened to their concerns, clarified expectations and [action taken]. This resulted in [outcome]. I learned that building trust requires clear communication and following through on commitments.",
                    category: .behavioural
                )
            ]

        case "jpmorganchase":
            return [
                SeedInterviewQuestion(
                    question: "How would you assess a company's financial health before an investment banking transaction?",
                    exampleAnswer: "I would examine revenue growth, profitability, cash flow, debt levels and relevant industry conditions. In [course or project], I analysed [financial dataset or business case] using [method or tool] and found [key insight]. I would use a similar evidence-based approach while recognising that a full assessment also depends on valuation, market conditions and transaction objectives.",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "What recent market or economic development could affect investment banking activity?",
                    exampleAnswer: "One development I have been following is [recent economic or market development]. It could affect investment banking through [impact on interest rates, valuations, financing or mergers and acquisitions]. I would assess its implications by examining [relevant indicators] and considering how different industries might respond.",
                    category: .company
                ),
                SeedInterviewQuestion(
                    question: "How would you check the accuracy of a financial model under a tight deadline?",
                    exampleAnswer: "I would validate the source data, check formulas and assumptions, compare outputs against independent calculations and test how changes in key inputs affect results. In [project or assignment], I checked [specific calculation or dataset] by [validation method], which helped me identify [issue or result]. I would also document assumptions and communicate any unresolved discrepancies.",
                    category: .technical
                )
            ]

        case "arup":
            return [
                SeedInterviewQuestion(
                    question: "How would you approach solving a mechanical engineering problem with several competing design constraints?",
                    exampleAnswer: "I would define the engineering requirements, identify constraints such as safety, performance, cost and sustainability, and compare feasible solutions against those criteria. In [engineering project or assignment], I evaluated [design problem] using [analysis or tool] and recommended [solution] because [reason]. I would validate the design against the relevant standards and requirements.",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "How would you contribute to a multidisciplinary engineering project at Arup?",
                    exampleAnswer: "I would clarify my responsibilities, communicate technical decisions clearly and coordinate with other disciplines to identify design dependencies. During [project], I worked on [your responsibility] alongside [other team or discipline] and helped resolve [challenge] through [action]. This led to [result].",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "How would you balance sustainability, safety and cost when evaluating an engineering solution?",
                    exampleAnswer: "I would treat safety and compliance as essential requirements, then compare feasible options using whole-of-life cost, energy use, environmental impact and performance. In [project or study], I considered [relevant trade-off] and selected [approach] because [evidence or reasoning]. I would document the assumptions and explain the trade-offs to stakeholders.",
                    category: .company
                )
            ]

        case "canva":
            return [
                SeedInterviewQuestion(
                    question: "How would you measure whether a marketing campaign had succeeded?",
                    exampleAnswer: "I would start with the campaign objective and select metrics that reflect it, such as reach, engagement, conversion rate or retention. In [project or campaign], I tracked [metric] using [tool or method] and found [result]. I would use those insights to identify what worked and improve the next campaign.",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "How would you adapt a Canva campaign for different audiences?",
                    exampleAnswer: "I would research each audience's needs, motivations and preferred channels, then adapt the message and creative format while maintaining a consistent brand identity. For [project or audience], I tailored [content or message] based on [research or feedback], which led to [result].",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "Why do you want to work at Canva, and how would you contribute to its mission?",
                    exampleAnswer: "I am interested in Canva's focus on making visual communication accessible. I particularly connect with [specific product, initiative or company value]. Through [project or experience], I developed skills in [relevant skills] and learned [lesson]. I would use these skills to help create marketing that makes Canva's products relevant and useful to its audiences.",
                    category: .company
                )
            ]

        case "kpmg":
            return [
                SeedInterviewQuestion(
                    question: "How would you investigate a discrepancy between two financial records?",
                    exampleAnswer: "I would reconcile the records, trace the difference to the original transactions, check for timing differences or data-entry errors and document the findings. In [assignment or experience], I investigated [discrepancy] by [steps taken] and identified [finding]. I would escalate unresolved issues and ensure any adjustment was appropriately supported.",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "What would you do if you discovered a potentially material accounting error?",
                    exampleAnswer: "I would verify the evidence, document the issue and raise it promptly with the appropriate supervisor. I would avoid making unsupported adjustments or concealing the discrepancy. In [relevant situation], I demonstrated integrity by [action], which resulted in [outcome].",
                    category: .behavioural
                ),
                SeedInterviewQuestion(
                    question: "How would you explain a complex financial finding to a client without an accounting background?",
                    exampleAnswer: "I would explain the finding in plain language, use a relevant example and connect it to the client's decisions. In [project or presentation], I explained [complex topic] to [audience] using [approach]. Their response or the outcome was [result]. I would check that the client understood the implications before discussing next steps.",
                    category: .role
                )
            ]

        case "asic":
            return [
                SeedInterviewQuestion(
                    question: "How would you research a policy issue involving potential harm to financial consumers?",
                    exampleAnswer: "I would define the policy problem, review relevant legislation and existing research, examine available evidence and identify affected consumer groups. In [research project], I investigated [issue] using [sources or method] and identified [finding]. I would assess the strength of the evidence and distinguish established facts from assumptions.",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "How would you use data to support a financial regulation policy recommendation?",
                    exampleAnswer: "I would identify indicators relevant to the policy objective, assess data quality and look for patterns or differences across affected groups. In [data or research project], I used [tool or method] to analyse [dataset] and found [insight]. I would consider limitations, alternative explanations and the potential consequences of each policy option.",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "Why does ASIC's role in protecting consumers and maintaining market integrity interest you?",
                    exampleAnswer: "I am interested in how effective regulation supports confidence in Australia's financial system and protects consumers from misconduct. I am particularly interested in [specific regulatory issue or ASIC initiative]. Through [study or experience], I developed skills in [research, analysis or communication], which I would apply to evidence-based policy work.",
                    category: .company
                )
            ]

        case "deloitte":
            return [
                SeedInterviewQuestion(
                    question: "How would you approach a client problem when the cause is not immediately clear?",
                    exampleAnswer: "I would clarify the client's objective, gather relevant information, break the problem into manageable parts and test possible causes against the evidence. In [project], I investigated [problem] by [approach] and identified [finding]. I would communicate my reasoning and recommend next steps based on the evidence.",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "Tell me about a time you had to explain a technical idea to a non-technical audience.",
                    exampleAnswer: "During [situation], I needed to explain [technical concept] to [audience]. I focused on the practical problem, used [analogy, visualisation or example] and checked their understanding. As a result, [outcome]. I learned to adapt the level of technical detail to the audience's needs.",
                    category: .behavioural
                ),
                SeedInterviewQuestion(
                    question: "How could technology help an organisation improve its operations?",
                    exampleAnswer: "I would first identify the operational bottleneck and understand the needs of the people using the process. For [project or business problem], I used [technology or method] to improve [process], achieving [result]. For a client, I would also evaluate implementation costs, security, adoption risks and how success would be measured.",
                    category: .technical
                )
            ]

        case "ashurst":
            return [
                SeedInterviewQuestion(
                    question: "How would you research an unfamiliar legal issue under a tight deadline?",
                    exampleAnswer: "I would define the legal question, locate relevant legislation and authoritative cases, verify that the sources remain applicable and summarise the implications. In [research or academic task], I investigated [issue] using [sources or method] and produced [outcome]. I would clearly identify uncertainties and seek guidance where necessary.",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "How can commercial developments affect the advice a law firm gives its clients?",
                    exampleAnswer: "Commercial developments can change a client's risks, priorities and available options. For [industry or example], a development such as [market or regulatory change] could affect [contracts, transactions or compliance obligations]. I would consider the legal position alongside the client's objectives and explain the practical implications clearly.",
                    category: .company
                ),
                SeedInterviewQuestion(
                    question: "How would you handle confidential information if someone requested details they were not authorised to receive?",
                    exampleAnswer: "I would avoid disclosing the information, verify the person's authority and follow the firm's confidentiality and escalation procedures. In [relevant situation], I handled sensitive information by [action]. This reinforced the importance of exercising judgement, maintaining professional boundaries and asking for guidance when uncertain.",
                    category: .behavioural
                )
            ]

        case "aecom":
            return [
                SeedInterviewQuestion(
                    question: "What factors would you investigate when conducting an environmental assessment?",
                    exampleAnswer: "I would establish the project scope, identify relevant environmental receptors and review baseline conditions, applicable standards and potential impacts. In [environmental or science project], I assessed [issue] using [method or tool] and found [result]. I would document assumptions, data limitations and appropriate mitigation options.",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "How would you respond if field data was incomplete or inconsistent?",
                    exampleAnswer: "I would check the collection methods, equipment records and quality controls, then identify which observations need verification or additional sampling. In [project or laboratory task], I addressed [data-quality issue] by [action], resulting in [outcome]. I would document limitations rather than draw conclusions unsupported by the evidence.",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "How would you communicate environmental risks to stakeholders with different priorities?",
                    exampleAnswer: "I would explain the evidence, potential impacts and mitigation options in language suited to each audience. In [project or presentation], I communicated [complex finding] to [audience] using [approach]. This helped achieve [outcome]. I would acknowledge legitimate concerns while ensuring the environmental evidence remained accurate.",
                    category: .behavioural
                )
            ]

        case "westpac":
            return [
                SeedInterviewQuestion(
                    question: "How would you help improve the recruitment experience for candidates?",
                    exampleAnswer: "I would map the candidate journey, gather feedback and look for delays or unclear communication. In [project or experience], I improved [process or user experience] by [action], resulting in [outcome]. I would measure candidate satisfaction, completion rates and time to hire to evaluate improvements.",
                    category: .role
                ),
                SeedInterviewQuestion(
                    question: "How could people analytics help an organisation make better HR decisions?",
                    exampleAnswer: "People analytics can help identify patterns in recruitment, retention, engagement and workforce development. For [business question], I would analyse [relevant data] using [tool or method] and examine [metric]. I would account for privacy, data quality and potential bias before recommending [action].",
                    category: .technical
                ),
                SeedInterviewQuestion(
                    question: "How would you approach an employee engagement initiative for a diverse workforce?",
                    exampleAnswer: "I would gather input from different employee groups, identify barriers to participation and develop initiatives suited to their needs. In [project or leadership experience], I worked with [group] to address [challenge] by [action]. The outcome was [result]. I would evaluate feedback and participation data to refine the initiative.",
                    category: .behavioural
                )
            ]

        default:
            return []
        }
    }
}
