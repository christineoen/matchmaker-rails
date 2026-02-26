import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectedCourts", "noMessage", "courtCard"]

  connect() {
    this.courtCardTargets.forEach(card => {
      if (card.dataset.selected === "true") this.#select(card)
    })
    this.#updateMessage()
  }

  select(event) {
    this.#select(event.currentTarget)
  }

  deselect(event) {
    const id = `${event.params.id}`
    this.selectedCourtsTarget.querySelector(`[data-court-badge="${id}"]`)?.remove()
    const card = this.courtCardTargets.find(c => c.dataset.courtId === id)
    if (card) {
      card.hidden = false
      card.style.display = ""
    }
    this.#updateMessage()
  }

  search(event) {
    const q = event.target.value.toLowerCase()
    this.courtCardTargets.forEach(card => {
      if (card.hidden) return
      card.style.display = card.dataset.search.toLowerCase().includes(q) ? "" : "none"
    })
  }

  #select(card) {
    const { courtId: id, courtName: name, courtSurface: surface } = card.dataset
    if (this.selectedCourtsTarget.querySelector(`[data-court-badge="${id}"]`)) return

    card.hidden = true

    const badge = document.createElement("div")
    badge.dataset.courtBadge = id
    badge.className = "flex items-center justify-between gap-2 pl-3 pr-2 py-2 border border-blue-200 bg-blue-50 rounded-lg"
    badge.innerHTML =
      `<input type="hidden" name="court_ids[]" value="${id}">` +
      `<div><p class="text-sm font-medium text-gray-900">Court ${name}</p>` +
      `<p class="text-xs text-gray-500 capitalize">${surface}</p></div>` +
      `<button type="button" data-action="court-picker#deselect" data-court-picker-id-param="${id}"` +
      ` class="text-gray-400 hover:text-gray-700 text-xl font-bold leading-none">&times;</button>`
    this.selectedCourtsTarget.appendChild(badge)
    this.#updateMessage()
  }

  #updateMessage() {
    const hasBadges = this.selectedCourtsTarget.querySelector("[data-court-badge]")
    this.noMessageTarget.style.display = hasBadges ? "none" : ""
  }
}
