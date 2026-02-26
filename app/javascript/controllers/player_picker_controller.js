import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectedPlayers", "noMessage", "playerCard"]

  connect() {
    this.playerCardTargets.forEach(card => {
      if (card.dataset.selected === "true") this.#select(card)
    })
    this.#updateMessage()
  }

  select(event) {
    this.#select(event.currentTarget)
  }

  deselect(event) {
    const id = `${event.params.id}`
    this.selectedPlayersTarget.querySelector(`[data-player-row="${id}"]`)?.remove()
    const card = this.playerCardTargets.find(c => c.dataset.playerId === id)
    if (card) {
      card.hidden = false
      card.style.display = ""
    }
    this.#updateMessage()
  }

  search(event) {
    const q = event.target.value.toLowerCase()
    this.playerCardTargets.forEach(card => {
      if (card.hidden) return
      card.style.display = card.dataset.search.toLowerCase().includes(q) ? "" : "none"
    })
  }

  #select(card) {
    const id = card.dataset.playerId
    if (this.selectedPlayersTarget.querySelector(`[data-player-row="${id}"]`)) return

    card.hidden = true

    const tpl = document.getElementById(`player-tpl-${id}`)
    if (!tpl) return
    this.selectedPlayersTarget.appendChild(document.importNode(tpl.content, true))
    this.#updateMessage()
  }

  #updateMessage() {
    const hasRows = !!this.selectedPlayersTarget.querySelector("[data-player-row]")
    this.noMessageTarget.style.display = hasRows ? "none" : ""
  }
}
