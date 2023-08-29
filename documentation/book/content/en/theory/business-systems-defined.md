+++
title = "What is a \"Business System\"?"
linkTitle = "What is a \"Business System\"?"
description = "In this section we'll ask and answer the question of what we mean when we talk about \"business systems\".  We'll also discuss why these systems exist and characterize how organizations use them to advantage (or not)."

draft = true

weight = 10
+++

The phrase "business system" can refer to any computer system supporting business operations, but here we mean it to be something very specific: a system used to coordinate business activities across different operating units of a company or corporate division and record the results of those activities.

Historically such systems are called "Enterprise Resource Planning" (ERP) systems.  This term is still used broadly today, but we'll not use this term in our documentation.  ERP systems are widely viewed negatively and with good reason: companies building and implementing ERP systems offer sprawling, labyrinthine applications that are difficult to configure and operate, are sold with expensive professional services engagements to implement, and often times are sold on false promises of effortless benefit.  While some of these realities of ERP system adoption are unavoidable, others are simply the result of low quality offerings designed to maximize software and service profits without incurring the expense of developing higher quality products.

Our position is that there is real value that can be extracted from a business system implementation so long as the offering is built understanding business realities and that the staff tasked with incorporating these systems into their business operations understand the system realities and the related trade-offs of utilizing system functions and features.  

## The Obvious

Adding detail our initial definition of "business system" we can describe what business system software is in terms that will be most familiar to those that use it on a daily basis.

Business systems coordinate and record business activities through the entry of "transaction documents" (transactions) into the system.  These transactions record the activities of typical business functional areas:

### Internally Servicing Departments

<div class="d-flex flex-row flex-wrap justify-content-start gap-5">
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Accounting</h4>
    <ul>
      <li>Ledger Control</li>
      <li>Accounts Receivable</li>
      <li>Accounts Payable</li>
      <li>Inventory Accounting</li>
      <li>Treasury Management</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Human Resources</h4>
    <ul>
      <li>Personnel Action Records</li>
      <li>Payroll Management</li>
      <li>Labor Scheduling</li>
      <li>Training & Compliance</li>
      <li>Recruiting Management</li> 
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Facilities & Maintenance</h4>
    <ul>
      <li>Request Management</li>
      <li>Service Records</li>
      <li>Incident Records</li>
      <li>Asset Management</li>
      <li>Maintenance Schedules</li>
      <li>Project Management</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Information Technology</h4>
    <ul>
      <li>Request Management</li>
      <li>Service Records</li>
      <li>Incident Records</li>
      <li>Asset Management</li>
      <li>Project Management</li>
    </ul>
  </div>
</div>

### Operating Departments

<div class="d-flex flex-row flex-wrap justify-content-start gap-5">
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Sales & Marketing</h4>
    <ul>
      <li>Campaign Management</li>
      <li>Lead/Opportunity Management</li>
      <li>Sales Quotes</li>
      <li>Sales Ordering</li>
      <li>Fulfillment Management</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Customer Support</h4>
    <ul>
      <li>Request Management</li>
      <li>Service Records</li>
      <li>Incident Records</li>
      <li>Returns Management</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Procurement</h4>
    <ul>
      <li>Vendor Management</li>
      <li>Purchase Ordering</li>
      <li>Vendor Returns</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Manufacturing</h4>
    <ul>
      <li>Work Ordering</li>
      <li>Production Scheduling</li>
      <li>Asset Management</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Retail Operations</h4>
    <ul>
      <li>Point of Sales</li>
      <li>Cash Management</li>
      <li>Labor Scheduling</li>
      <li>Inventory Management</li>
    </ul>
  </div>
  <div class="d-flex flex-column">
    <h4 class="fw-bold">Warehouse Management</h4>
    <ul>
      <li>Inventory Management</li>
      <li>Inventory Shipping</li>
      <li>Inventory Receiving</li>
    </ul>
  </div>
</div>

Naturally, the lists above can be constructed differently, at different granularity, or using other organizing principles but the gist is that all these different areas of the business can be operated from a full featured business system.  Implicit in running in a common system, and a benefit of so doing, is that cross-functional activities can be coordinated and reported on without having to create ad hoc processes to do so; the business system provides the framework for collaboration and reporting across all of the business's units. 

## Deeper Purpose

Looking behind the business activities of a typical company, a business system's features can be reduced to three principle activities or functional areas of concern:

### Accounting

The accounting function is geared towards reporting on the financial outcomes of the business's activities, ensuring that those activities were conducted in accordance with the company's policies, and are recorded accurately.  

The primary product of the accounting function are the corporate financial statements prepared for investors, lending institutions, and regulatory/taxing authorities.  To ensure that financial statements are accurate, and to limit risks to the business, controls are established regarding which members of staff may conduct business on behalf of the company and dictate the standards to which business transactions are recorded.  Finally, reconciliation and audits of the business records and financial statements are conducted to find errors or unauthorized transactions.

Importantly, this is the domain of financial accounting were the accurate recording and reporting of information is done under the auspices of the professional accounting standards (i.e. the [Generally Accepted Accounting Principles](https://www.fasb.org/standards) or the [International Financial Reporting Standards](https://www.ifrs.org/issued-standards/list-of-standards/)) or according to the rules of the pertinent regulatory or taxing authorities.

### Business Operations Support

Supporting business operations involves maintaining records of business relationships and entities (in the general sense), process automation, and facilitating business communication between staff members internally and with business partners externally.

Initially and on an ongoing basis staff will create lists of entities in the system which are pertinent to business operations.  Entities may include relationships such as vendors and customers or other kinds of entities such as products or company facilities.  These entities will then be used to standardize the recording of business transactions in the system.

Transaction processing from the business operations perspective in principally focused on managing the life-cycle of the transactions.  A sales quote may eventually become a sales order which in turn will need to be fulfilled or it may be cancelled or the product returned for some reason.  This all has bearing on what actions must be performed by staff.  Reviewing transactions in the system can indicate to staff what work must be done or is no longer needed.

As transaction processing moves through the business system, the system can centralize and facilitate communication across operating departments and even with relevant third parties. In our sales example from the previous paragraph, a shipping department may record that a product on the sales order is not available which the sales department will be able to see; the sales demand from the order may cause an automatic purchase order for the product to be placed with the appropriate vendor.  

### Analytics

Information collected in support of business operations or for accounting can be used to gain deeper insights into the functioning of the business relative to the planning of managers, may be used to uncover opportunities, or expose risks.  The range of analytics can cover anything from the basic regular reporting of key performance indicators to more advanced trending and statistical analysis of operations.

Analytic reporting is in the domain of management accounting practices. Representations of financial information may depart from those of financial accounting and the financial statements.  For example, many manufacturing businesses use the Standard Cost methodology of inventory item costing which uses projected costs for items and inventory analysis rather than costs derived from actual transactions; this is helpful for understanding variances from the planned costs of manufacturing, but is not allowed for valuation purposes by any of the financial accounting standards.

Also unique to the analysis area of concern are long range concerns.  Analysis of results and projects may well include multiple years of past results or project performance into the distant future.  Accounting and business operation concerns, however, are usually much more immediate and sensitive to current conditions.
  
## Inferences

With an understanding of the basic functions and the defined areas of concern, we can arrive at some basic inferences about how users interact with the system.  

### User Intent

When a user sits down to use the system, they are typically doing so in service of only one of the three areas of concern described above.  This isn't to say that an individual staff member will only ever be interest in a single area of concern, but that any one task to be completed will focus on a single area of concern.

