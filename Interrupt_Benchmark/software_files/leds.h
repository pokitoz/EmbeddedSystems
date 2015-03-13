#ifndef LEDS_H_
#define LEDS_H_

/**
 * \brief Set the leds given by mask
 * \param[in] mask the leds to set to 1
 */
void leds_set(const char mask);

/**
 * \brief Clear the leds given by mask
 * \param[in] mask the leds to set to 0
 */
void leds_clr(const char mask);

/**
 * \brief Change value of the leds
 * \param[in] value the new value for the leds
 */
void leds(const char value);

#endif /* LEDS_H_ */
