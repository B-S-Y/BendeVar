<h1 align="center">Bende Var</h1>

<p align="center">
  <b>What you need is already in your community.</b><br>
  A mobile app where people who share the same place : a school, a dorm or a company , meet each other's needs.
</p>

<p align="center">
  <img src="docs/screens/01-welcome.png" width="180" alt="Welcome screen">
  <img src="docs/screens/13-my-profile.png" width="180" alt="My profile">
  <img src="docs/screens/14-offers.png" width="180" alt="My requests and offers">
  <img src="docs/screens/15-qr-code.png" width="180" alt="QR handover code">
</p>

<p align="center">
  MTM4681 Mobile Programming · Yıldız Technical University · Milestone 1 (Design and architecture) 
</p>

---

## Contents
- [About the app](#about-the-app)
- [How it works](#how-it-works)
- [Key screens](#key-screens)
- [Figma: wireframes, mockups and prototype](#figma-wireframes-mockups-and-prototype)
- [Milestone 1 deliverables](#milestone-1-deliverables)
- [Team](#team)
- [Technology and architecture](#technology-and-architecture)
- [Repository structure](#repository-structure)

## About the app

On campus you suddenly need a calculator; in the dorm, an extension cord; for a weekend trip, a camping chair. Most of the time that item is just a few doors away, sitting unused. **Bende Var** ("I have it") brings people in the same community together at exactly that moment.

- Every community (school, dorm, company) has its own group. Users join it with their **institutional email**, so everyone really belongs to the same place.
- Users post a **request** for something they want to borrow or buy. Someone who has the item replies **"Bende var"** with an offer.
- The two sides agree on the price or the loan period by messaging each other.
- There is no in-app payment. Payment happens face to face or by bank transfer (IBAN).
- Borrowed items come with **return reminders**. Handover and return are confirmed with a **QR code**.

## How it works

| 1 · Join | 2 · Ask or share | 3 · Agree | 4 · Hand over and get it back |
| --- | --- | --- | --- |
| Sign up with your institutional email; you automatically join your school's community. | Post a request, or list an item you can lend or sell; reply "Bende var" to someone else's request. | Compare the offers you receive, negotiate by message, accept one. | Confirm the handover by scanning a QR code when you meet; get a reminder on the return day, complete the return with a QR code and rate the other person. |

## Key screens

> The designs use the "E · Midnight" palette (navy #0B1D45, silver #A9B2C2, surface #EEF1F6, accent blue #2F5FC4). See the [Figma prototype](#figma-wireframes-mockups-and-prototype) for every screen and the transitions between them. The screens themselves are in Turkish.

<table>
  <tr>
    <th>Sign in<br><sub>Member 1</sub></th>
    <th>Discover<br><sub>Member 2</sub></th>
    <th>Post a listing<br><sub>Member 3</sub></th>
    <th>Messages<br><sub>Member 4</sub></th>
    <th>Profile &amp; QR<br><sub>Member 5</sub></th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screens/01-welcome.png" width="140"><br><sub>1.01 · Welcome</sub></td>
    <td align="center"><img src="docs/screens/04-home.png" width="140"><br><sub>2.01 · Home</sub></td>
    <td align="center"><img src="docs/screens/07-create-listing.png" width="140"><br><sub>3.01 · Create a listing</sub></td>
    <td align="center"><img src="docs/screens/11-chat.png" width="140"><br><sub>4.05 · Chat</sub></td>
    <td align="center"><img src="docs/screens/13-my-profile.png" width="140"><br><sub>5.01 · My profile</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screens/03-sign-up.png" width="140"><br><sub>1.08 · Sign up</sub></td>
    <td align="center"><img src="docs/screens/06-bende-var-offer.png" width="140"><br><sub>2.07 · "Bende var" offer</sub></td>
    <td align="center"><img src="docs/screens/09-listing-preview.png" width="140"><br><sub>3.06 · Listing preview</sub></td>
    <td align="center"><img src="docs/screens/12-notifications.png" width="140"><br><sub>4.07 · Notifications</sub></td>
    <td align="center"><img src="docs/screens/15-qr-code.png" width="140"><br><sub>5.21 · QR handover code</sub></td>
  </tr>
</table>
